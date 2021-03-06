(define-module net.twitter.base
  (use net.twitter.core)
  (use srfi-1)
  (use net.oauth)
  (use gauche.parameter)
  (use rfc.822)
  (use rfc.http)
  (use rfc.json)
  (use rfc.mime)
  (use util.list)
  (use util.match)
  (use text.tr)
  (use sxml.ssax)
  (use sxml.sxpath))
(select-module net.twitter.base)

;;
;; A convenience macro to construct query parameters, skipping
;; if #f is given to the variable.
;; keys are keyword list that append to vars after parsing.
(define-macro (api-params keys . vars)
  `(with-module net.twitter.base
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

(define (call/oauth cred method path params . opts)
  (apply call/oauth-internal
         cred method (->resource-path path) params #f opts))

(define (->resource-path path)
  (cond
   [(#/\.xml$/ path) path]
   [(#/\.json$/ path) path]
   [else #`",|path|.json"]))

(define (call/oauth-internal cred method path params body . opts)
  (define (call)
    (let* ([server (if (eq? method 'upload-file)
                     "upload.twitter.com"
                     "api.twitter.com")]
           [auth (and cred
                      (oauth-auth-header
                       (if (eq? method 'get) "GET" "POST")
                       (build-url server path) params cred))])
      (case method
        ['get
         (apply http-get server
                #`",|path|?,(oauth-compose-query params)"
                :Authorization auth :secure (twitter-use-https)
                :content-type "application/x-www-form-urlencoded"
                opts)]
        ['post
         (apply http-post server path
                (oauth-compose-query params)
                :Authorization auth :secure (twitter-use-https)
                :content-type "application/x-www-form-urlencoded"
                opts)]
        [(post-file upload-file)
         (hack-mime-composing
          (apply http-post server
                 (if (pair? params) #`",|path|?,(oauth-compose-query params)" path)
                 body
                 :Authorization auth :secure (twitter-use-https)
                 :content-type (if body "multipart/form-data" "application/octet-stream")
                 opts))])))

  (define (retrieve status headers body)
    (%api-adapter status headers body))

  (call-with-values call retrieve))

(define (call/oauth-post->json cred path files params . opts)
  (apply call/oauth-internal
         cred 'post-file (->resource-path path) params files opts))

(define (call/oauth-upload->json cred path files params . opts)
  (apply call/oauth-internal
         cred 'upload-file (->resource-path path) params files opts))

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
    (let1 code (string->number status)
      (unless (and (<= 200 code) (< code 300))
        (raise-api-error type status headers body)))
    (ecase type
      ['xml
       (values (parse-xml-string body) headers)]
      ['json
       (values (parse-json-string body) headers)]
      ['html
       (values body headers)])))

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

(define (stringify-param obj)
  (cond
   [(not obj) #f]
   [(pair? obj)
    ($ (cut string-join <> ",") $ map x->string obj)]
   [(string? obj)
    obj]
   [else
    (x->string obj)]))

