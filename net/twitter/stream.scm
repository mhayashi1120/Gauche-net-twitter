(define-module net.twitter.stream
  (extend net.twitter.base)
  (use gauche.parameter)
  (use net.oauth)
  (use net.twitter.core)
  (use rfc.http)
  (use rfc.uri)
  (use srfi-13)
  (use text.parse)
  (use gauche.threads)
  (use rfc.json)

  (export
   stream-timeout connection-timeout
   user-stream sample-stream filter-stream

   ;; experimental
   firehose-stream site-stream
   ))
(select-module net.twitter.stream)

;;;
;;; Stream API
;;;

;; https://dev.twitter.com/docs/streaming-apis/connecting#Stalls
(define stream-timeout
  (make-parameter 90))

;; Timeout seconds when opening stream connection (default: 5sec)
(define connection-timeout
  (make-parameter 5))

;; https://dev.twitter.com/docs/streaming-apis
;; https://dev.twitter.com/docs/streaming-apis/streams/public

;; TODO http://practical-scheme.net/chaton/gauche/a/2011/02/11
;; PROC accept one string (JSON) and optionally accept next arg as JSON sexp.
(define (user-stream cred proc :key (replies #f) (delimited #f)
                     (stall-warnings #f) (with #f) (track #f)
                     (locations #f) (stringify-friend-ids #f)
                     (raise-error? #f) (error-handler #f)
                     :allow-other-keys _keys)
  (set! track (stringify-param track))
  (open-stream cred proc 'post "https://userstream.twitter.com/1.1/user.json"
               (api-params _keys replies delimited stall-warnings
                           with track locations stringify-friend-ids)
               :error-handler (or error-handler raise-error?)))

(define (sample-stream cred proc :key (delimited #f) (stall-warnings #f)
                       (raise-error? #f) (error-handler #f)
                       :allow-other-keys _keys)
  (open-stream cred proc 'get "https://stream.twitter.com/1.1/statuses/sample.json"
               (api-params _keys delimited stall-warnings)
               :error-handler (or error-handler raise-error?)))

(define (filter-stream cred proc :key (follow #f) (track #f)
                       (locations #f) (delimited #f) (stall-warnings #f)
                       (raise-error? #f) (error-handler #f)
                       :allow-other-keys _keys)
  (set! track (stringify-param track))
  (set! follow (stringify-param follow))
  (open-stream cred proc 'post "https://stream.twitter.com/1.1/statuses/filter.json"
               (api-params _keys delimited follow locations track stall-warnings)
               :error-handler (or error-handler raise-error?)))

;;TODO not yet checked
(define (firehose-stream cred proc :key (count #f) (delimited #f)
                         (stall-warnings #f)
                         (raise-error? #f) (error-handler #f)
                         :allow-other-keys _keys)
  (open-stream cred proc 'get "https://stream.twitter.com/1.1/statuses/firehose.json"
               (api-params _keys count delimited stall-warnings)
               :error-handler (or error-handler raise-error?)))

;;TODO not yet checked
(define (site-stream cred proc :key (follow #f) (delimited #f) (stall-warnings #f)
                     (with #f) (replies #f) (raise-error? #f) (error-handler #f)
                     (stringify-friend-ids #f)
                     :allow-other-keys _keys)
  (set! follow (stringify-param follow))
  (open-stream cred proc 'get "https://sitestream.twitter.com/1.1/site.json"
               (api-params _keys follow delimited stall-warnings
                           with stringify-friend-ids replies)
               :error-handler (or error-handler raise-error?)))

;;;
;;; Internal methods
;;;

(define (open-stream cred proc method url params
                     :key (error-handler #f))

  (define (auth-header)
    (ecase method
      ['get
       (oauth-auth-header "GET" url params cred)]
      ['post
       (oauth-auth-header "POST" url params cred)]))

  (define json-handler
    (cond
     [(= (arity proc) 1)
      (^ [string _] (proc string))]
     [(= (arity proc) 2)
      (^ [string sexp] (proc string sexp))]))

  (define (stream-looper code headers total retrieve)
    (guard (e [else (thread-specific-set! (current-thread) e)])
      (check-stream-error code headers)
      (let loop ([buf (open-output-string)]
                 ;; If retrieved PORT contains
                 ;;  <html><head>503<head> ...
                 ;; This may cause exhausting memory.
                 ;; Over 10 times continuing RETRIEVE to a BUF,
                 ;; reset the BUF.
                 [limit 10])
        (receive (port size) (retrieve)
          (set! last-arrived (sys-time))
          (cond
           [(negative? size)
            (error "Connection is closed by remote")]
           [else
            (copy-port port buf :unit 'byte :size size)
            (cond
             [(and-let* ([s (get-output-string buf)]
                         [trimmed (string-trim-both s #[\x0d\x0a ])]
                         [(not (string-null? trimmed))]
                         [json-sexp (guard (e [else #f])
                                      (parse-json-string trimmed))])
                (list trimmed json-sexp)) =>
                (^j
                 (close-output-port buf)
                 (apply json-handler j)
                 (loop (open-output-string) 10))]
             [(= limit 0)
              ;; reset BUF
              (loop (open-output-string) 10)]
             [else
              (loop buf (- limit 1))])])))))

  (define (connect)
    (let1 auth (auth-header)
      (receive (scheme host path) (parse-uri url)
        (set! last-arrived #f)
        (ecase method
          ['get
           (http-get host (if (pair? params)
                            #`",|path|?,(oauth-compose-query params)"
                            path)
                     :secure (string=? "https" scheme)
                     :receiver stream-looper
                     :Authorization auth)]
          ['post
           (http-post host (if (pair? params)
                             #`",|path|?,(oauth-compose-query params)"
                             path)
                      ""
                      :secure (string=? "https" scheme)
                      :receiver stream-looper
                      :Authorization auth)]))))

  (define adapt-error (construct-error-handler error-handler))

  (define (check-stream-error status headers)
    (cond
     [(equal? status "200")
      ;; reset error adapter
      (set! adapt-error (construct-error-handler error-handler))]
     [else
      (error <twitter-api-error>
             :status status :headers headers
             (format "Failed to open stream with code ~a"
                     status))]))

  ;; TODO, FIXME: partcont procedure can't execute in thread.
  (define last-arrived #f)

  (define (sticky-connect)
    (while #t
      (guard (e [else (adapt-error e)])
        (let* ([con-limit (+ (sys-time) (connection-timeout))]
               [th (make-thread connect)])
          ;; thread which hold http stream connection
          (thread-start! th)
          (unwind-protect
           (while #t
             (sys-nanosleep 100000000)
             (cond
              [(not (eq? (thread-state th) 'runnable))
               (if-let1 e (thread-specific th)
                 (raise e)
                 (errorf "Thread ~a unexpectedly" (thread-state th)))]
              [(not last-arrived)
               ;; wait until connection limit time
               (when (< con-limit (sys-time))
                 (error <twitter-timeout-error>
                        (format "Connect to stream timed-out. ~s" th)))]
              [(< last-arrived (- (sys-time) (stream-timeout)))
               (errorf <twitter-timeout-error>
                       "Stream packet arrival timed-out. (at ~s)" last-arrived)]))
           (thread-terminate! th))))))

  (sticky-connect))

;; https://dev.twitter.com/docs/streaming-apis/connecting#Reconnecting
(define (construct-error-handler handler)

  (define tcpip-waitsec 0)
  (define too-often-waitsec 60)
  (define http-waitsec 5)

  (cond
   [(eq? handler #t)
    (^e (raise e))]
   [else
    (^e
     (when handler (handler e))
     ;; reconnect if handler has no error
     (cond
      [(<twitter-api-error> e)
       (cond
        [(equal? "420" (condition-ref e 'status))
         ;; Login too often
         (sys-sleep too-often-waitsec)
         (set! too-often-waitsec
               (* too-often-waitsec 2))]
        [(#/^4/ (condition-ref e 'status))
         ;; eternal error
         (raise e)]
        [else
         (sys-sleep http-waitsec)
         (set! http-waitsec
               (min (* http-waitsec 2) 320))])]
      [else
       (set! tcpip-waitsec (min (+ tcpip-waitsec 0.25) 16))
       (sys-nanosleep (* tcpip-waitsec 1000000))]))]))

(define (parse-uri uri)
  (receive (scheme spec) (uri-scheme&specific uri)
    (receive (host path . _) (uri-decompose-hierarchical spec)
      (values scheme host path))))

