(define-module net.twitter.stream
  (use net.oauth)
  (use net.twitter.core)
  (use rfc.http)
  (use rfc.json)
  (use rfc.uri)
  (use srfi-13)
  (use text.parse)
  (use util.list)
  (export
   user-stream
   sample-stream
   filter-stream
   retweet-stream
   firehose-stream
   links-stream
   site-stream
   ))
(select-module net.twitter.stream)

;;;
;;; Stream API
;;;

;; https://dev.twitter.com/docs/streaming-api/methods
;; https://dev.twitter.com/docs/streaming-api

;;TODO about http-user-agent

;; TODO http://practical-scheme.net/chaton/gauche/a/2011/02/11
;; proc accept one arg
;; TODO error-handler keyword
(define (user-stream cred proc :key (replies #f) (raise-error? #f))
  (open-stream cred proc 'post "https://userstream.twitter.com/2/user.json"
               (make-query-params replies) :raise-error? raise-error?))

(define (sample-stream cred proc :key (count #f) (delimited #f)
                       (raise-error? #f))
  (open-stream cred proc 'get "https://stream.twitter.com/1/statuses/sample.json"
               (make-query-params count delimited) :raise-error? raise-error?))

(define (filter-stream cred proc :key (count #f) (delimited #f)
                       (follow #f) (locations #f) (track #f)
                       (stall-warnings #f)
                       (raise-error? #f))
  ;;FIXME too many follow make excessive URL length.
  (open-stream cred proc 'post "https://stream.twitter.com/1/statuses/filter.json"
               (make-query-params count delimited follow locations track)
               :raise-error? raise-error?))

;;TODO not works
(define (retweet-stream cred proc :key (delimited #f) (stall-warnings #f)
                        (raise-error? #f))
  (open-stream cred proc 'get "https://stream.twitter.com/1/statuses/retweet.json"
               (make-query-params delimited stall-warnings)
               :raise-error? raise-error?))

;;TODO not works
(define (firehose-stream cred proc :key (count #f) (delimited #f)
                         (raise-error? #f))
  (open-stream cred proc 'get "https://stream.twitter.com/1/statuses/firehose.json"
               (make-query-params count delimited)
               :raise-error? raise-error?))

;;TODO not works
(define (links-stream cred proc :key (count #f) (delimited #f)
                      (stall-warnings #f) (raise-error? #f))
  (open-stream cred proc 'get "https://stream.twitter.com/1/statuses/links.json"
               (make-query-params count delimited stall-warnings)
               :raise-error? raise-error?))

;;TODO not works
;; beta tested
(define (site-stream cred proc :key (raise-error? #f))
  (open-stream cred proc 'get "https://sitestream.twitter.com/2b/site.json"
               (make-query-params)
               :raise-error? raise-error?))

;;TODO params
;;todo fallback when connection is broken
(define (open-stream cred proc method url params :key (raise-error? #f))

  (define (auth-header)
    (ecase method
      ['get
       (oauth-auth-header "GET" url params cred)]
      ['post
       (oauth-auth-header "POST" url params cred)]
      ['post-body
       (oauth-auth-header "POST" url '() cred)]))

  (define (stream-looper code headers total retrieve)
    (check-stream-error code headers)
    (let loop ()
      (guard (e [else
                 ;; TODO
                 (and raise-error? (raise e))])
        (receive (port size) (retrieve)
          (and-let* ([s (read-string size port)]
                     [json (safe-parse-json s)])
            (proc json))))
      (loop)))

  (define (check-stream-error status headers)
    (unless (equal? status "200")
      (error <twitter-api-error>
             :status status :headers headers
             "Failed opening stream")))

  (let1 auth (auth-header)
    (receive (scheme host path)
        (parse-uri url)
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
                    :Authorization auth)]
        ['post-body
         ;; When POSTing huge data.
         (http-post host path (if (pair? params)
                                (http-compose-form-data params #f)
                                "")
                    :secure (string=? "https" scheme)
                    :receiver stream-looper
                    :Authorization auth)]))))

(define (safe-parse-json string)
  ;; heading white space cause rfc.json parse error.
  (let1 trimmed (string-trim string)
    (and (> (string-length trimmed) 0)
         (parse-json-string trimmed))))

(define (parse-uri uri)
  (receive (scheme spec) (uri-scheme&specific uri)
    (receive (host path . rest) (uri-decompose-hierarchical spec)
      (values scheme host path))))

