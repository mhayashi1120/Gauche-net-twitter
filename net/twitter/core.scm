(define-module net.twitter.core
  (use srfi-1)
  (use gauche.parameter)
  (use net.oauth)
  (use rfc.822)
  (use rfc.http)
  (use rfc.json)
  (use rfc.mime)
  (use util.list)
  (use util.match)
  (use text.tr)
  (use sxml.ssax)
  (use sxml.sxpath)
  (export
   <twitter-cred> <twitter-api-error>
   api-params
   build-url
   retrieve-stream check-search-error
   call/oauth->json call/oauth
   call/oauth-post->json call/oauth-upload->json
   ))
(select-module net.twitter.core)

(define twitter-use-https
  (make-parameter #t))

;;
;; Credential
;;

(define-class <twitter-cred> (<oauth-cred>)
  ())

;;
;; Condition for error response
;;

(define-condition-type <twitter-api-error> <error> #f
  (status #f)
  (headers #f)
  (body #f)
  (body-sxml #f)
  (body-json #f))

;;
;; A convenience macro to construct query parameters, skipping
;; if #f is given to the variable.
;; keys are keyword list that append to vars after parsing.
(define-macro (api-params keys . vars)
  `(with-module net.twitter.core
     (append
      (query-params ,@vars)
      (let loop ([ks ,keys]
                 [res '()])
        (cond
         [(null? ks) (reverse! res)]
         [else
          (let* ([key (->param-key (car ks))]
                 [val (->param-value (cadr ks))])
            (cond
             [(not val)
              (loop (cddr ks) res)]
             [else
              (loop (cddr ks) (cons (list key val) res))]))])))))

(define-macro (query-params . vars)
  `(cond-list
    ,@(map (^v
            `(,v `(,',(->param-key v)
                   ,(->param-value ,v))))
           vars)))

(define (->param-key x)
  (string-tr (x->string x) "-" "_"))

(define (->param-value x)
  (cond
   [(eq? x #f) #f]
   [(eq? x #t) "t"]
   [else (x->string x)]))

(with-module rfc.mime
  (define (twitter-mime-compose parts
                                :optional (port (current-output-port))
                                :key (boundary (mime-make-boundary)))
    (for-each (cut display <> port) `("--" ,boundary "\r\n"))
    (dolist [p parts]
      (mime-generate-one-part (canonical-part p) port)
      (for-each (cut display <> port) `("\r\n--" ,boundary "--\r\n")))
    boundary))

(define (parse-xml-string str)
  (call-with-input-string str
    (cut ssax:xml->sxml <> '())))

(define (call/oauth->json cred method path params . opts)
  (apply call/oauth cred method #`",|path|.json" params opts))

(define (call/oauth cred method path params . opts)
  (let1 path
      (cond
       [(#/\.xml$/ path) path]
       [(#/\.json$/ path) path]
       [else #`",|path|.json"])

    (define (call)
      (let1 auth (and cred
                      (oauth-auth-header
                       (if (eq? method 'get) "GET" "POST")
                       (build-url "api.twitter.com" path) params cred))
        (case method
          [(get) (apply http-get "api.twitter.com"
                        #`",|path|?,(oauth-compose-query params)"
                        :Authorization auth :secure (twitter-use-https) opts)]
          [(post) (apply http-post "api.twitter.com" path
                         (oauth-compose-query params)
                         :Authorization auth :secure (twitter-use-https) opts)])))

    (define (retrieve status headers body)
      (%api-adapter status headers body))

    (call-with-values call retrieve)))

(define (call/oauth-post->json cred path files params . opts)
  (apply
   (call/oauth-file-sender "api.twitter.com")
   cred ",|path|.json" files params opts))

(define (call/oauth-upload->json cred path files params . opts)
  (apply
   (call/oauth-file-sender "upload.twitter.com")
   cred ",|path|.json" files params opts))

(define-macro (hack-mime-composing . expr)
  (let ([original (gensym)])
    `(let ([,original #f])
       (with-module rfc.mime
         (set! ,original mime-compose-message)
         (set! mime-compose-message twitter-mime-compose))
       (unwind-protect
        (begin ,@expr)
        (with-module rfc.mime
          (set! mime-compose-message ,original))))))

(define (call/oauth-file-sender host)
  (^ [cred path files params . opts]
    (define (call)
      (let1 auth (oauth-auth-header
                  "POST" (build-url host path) params cred)
        (hack-mime-composing
         (apply http-post host
                (if (pair? params) #`",|path|?,(oauth-compose-query params)" path)
                files :Authorization auth :secure (twitter-use-https) opts))))

    (define (retrieve status headers body)
      (%api-adapter status headers body))

    (call-with-values call retrieve)))

(define (build-url host path)
  (string-append
   (if (twitter-use-https) "https" "http")
   "://" host path))

(define (%api-adapter status headers body)
  (let1 type (if-let1 ct (rfc822-header-ref headers "content-type")
               (match (mime-parse-content-type ct)
                 [(_ "xml" . _) 'xml]
                 [(_ "json" . _) 'json]
                 [(_ "html" . _) 'html])
               (error <twitter-api-error>
                      :status status :headers headers :body body
                      body))
    (unless (equal? status "200")
      (raise-api-error type status headers body))
    (ecase type
      ['xml
       (values (parse-xml-string body) headers)]
      ['json
       (values (parse-json-string body) headers)])))

(define (raise-api-error type status headers body)
  (ecase type
    ['xml
     (let* ([body-sxml (guard (e [else '()]) (parse-xml-string body))]
            [msg (or ((if-car-sxpath '(// error *text*)) body-sxml) body)])
       (error <twitter-api-error>
              :status status :headers headers :body body
              :body-sxml body-sxml
              msg))]
    ['json
     (let* ([body-json (guard (e [else '()]) (parse-json-string body))]
            [aref assoc-ref]
            [vref vector-ref]
            [msg (or (and-let* ([errors (aref body-json "errors")]
                                [error0 (vref errors 0)]
                                [msg (aref error0 "message")])
                       msg)
                     body)])
       (error <twitter-api-error>
              :status status :headers headers :body body
              :body-json body-json
              msg))]
    ['html
     (error <twitter-api-error>
            :status status :headers headers :body body
            (parse-html-message body))]))

(define (check-search-error status headers body)
  (unless (equal? status "200")
    (or (and-let* ([ct (rfc822-header-ref headers "content-type")])
          (match (mime-parse-content-type ct)
            [(_ "xml" . _)
             (raise-api-error 'xml status headers body)]
            [(_ "json" . _)
             (raise-api-error 'json status headers body)]
            [(_ "html" . _)
             (raise-api-error 'html status headers body)]
            [_ #f]))
        (error <twitter-api-error>
               :status status :headers headers :body body
               body))))

;; select body elements text
(define (parse-html-message body)
  (let loop ([lines (string-split body "\n")]
			 [ret '()])
	(cond
     ((null? lines)
      (string-join (reverse ret) " "))
	 ((#/<h[0-9]>([^<]+)<\/h[0-9]>/ (car lines)) =>
	  (lambda (m)
        (loop (cdr lines) (cons (m 1) ret))))
     (else
      (loop (cdr lines) ret)))))

(define (retrieve-stream getter f . args)
  ;; getter: from f results then return list.
  (let loop ([cursor -1]
             [accum '()])
    (let* ([r (apply f (append args `(:cursor ,cursor)))]
           [next (assoc-ref r "next_cursor")]
           [res (cons (getter r) accum)])
      (if (equal? next 0)
        (concatenate (reverse res))
        (loop next res)))))
