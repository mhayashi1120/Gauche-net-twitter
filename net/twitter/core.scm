(define-module net.twitter.core
  (use srfi-1)
  (use gauche.parameter)
  (use net.oauth)
  (use rfc.822)
  (use rfc.http)
  (use rfc.json)
  (use rfc.mime)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use text.tr)
  (use util.list)
  (use util.match)
  (export 
   <twitter-cred> <twitter-api-error>
   make-query-params build-url
   retrieve-stream check-api-error
   call/oauth->sxml call/oauth
   call/oauth-post->sxml call/oauth-upload->sxml
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
;;
(define-macro (make-query-params . vars)
  `(cond-list
    ,@(map (lambda (v)
             `(,v `(,',(string-tr (x->string v) "-" "_") 
                    ,(cond
                      [(eq? ,v #t) "t"]
                      [else (x->string ,v)]))))
           vars)))

(with-module rfc.mime
  (define (twitter-mime-compose parts
                                :optional (port (current-output-port))
                                :key (boundary (mime-make-boundary)))
    (for-each (cut display <> port) `("--" ,boundary "\r\n"))
    (dolist [p parts]
      (mime-generate-one-part (canonical-part p) port)
      (for-each (cut display <> port) `("\r\n--" ,boundary "--\r\n")))
    boundary))

(define-macro (hack-mime-composing . expr)
  (let ((original (gensym)))
    `(let ((,original #f))
       (with-module rfc.mime
         (set! ,original mime-compose-message)
         (set! mime-compose-message twitter-mime-compose))
       (unwind-protect
        (begin ,@expr)
        (with-module rfc.mime
          (set! mime-compose-message ,original))))))

(define (call/oauth->sxml cred method path params . opts)
  (apply call/oauth (lambda (body) 
                      (call-with-input-string body (cut ssax:xml->sxml <> '())))
		 cred method path params opts))

(define (call/oauth parser cred method path params . opts)
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
    (check-api-error status headers body)
    (values (parser body) headers))

  (call-with-values call retrieve))

(define (call/oauth-post->sxml cred path files params . opts)

  (define (call)
    (let1 auth (oauth-auth-header 
                "POST" (build-url "api.twitter.com" path)
                params cred)
      (hack-mime-composing 
       (apply http-post "api.twitter.com" 
              (if (pair? params) #`",|path|?,(oauth-compose-query params)" path)
              files :Authorization auth :secure (twitter-use-https) opts))))

  (define (retrieve status headers body)
    (check-api-error status headers body)
    (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
            headers))

  (call-with-values call retrieve))

(define (call/oauth-upload->sxml cred path files params . opts)
  (define (call)
    (let1 auth (oauth-auth-header 
                "POST" (build-url "upload.twitter.com" path) params cred)
      (hack-mime-composing
       (apply http-post "upload.twitter.com" 
              #`",|path|?,(oauth-compose-query params)"
              files :Authorization auth :secure (twitter-use-https) opts))))

  (define (retrieve status headers body)
    (check-api-error status headers body)
    (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
            headers))

  (call-with-values call retrieve))

(define (build-url host path)
  (string-append
   (if (twitter-use-https) "https" "http")
   "://" host path))

(define (check-api-error status headers body)
  (unless (equal? status "200")
    (or (and-let* ([ct (rfc822-header-ref headers "content-type")])
          (match (mime-parse-content-type ct)
                 [(_ "xml" . _)
                  (let1 body-sxml
                      (guard (e (else #f))
                        (call-with-input-string body (cut ssax:xml->sxml <> '())))
                    (error <twitter-api-error>
                           :status status :headers headers :body body
                           :body-sxml body-sxml
                           (or (and body-sxml ((if-car-sxpath '(// error *text*)) body-sxml))
                               body)))]
                 [(_ "json" . _)
                  (let1 body-json
                      (guard (e (else #f))
                        (parse-json-string body))
                    (let ((aref assoc-ref)
                          (vref vector-ref))
                      (error <twitter-api-error>
                             :status status :headers headers :body body
                             :body-json body-json
                             (or (and body-json 
                                      (guard (e (else #f))
                                        (aref (vref (aref body-json "errors") 0) "message")))
                                 body))))]
                 [(_ "html" . _)
                  (error <twitter-api-error>
                         :status status :headers headers :body body
                         (parse-html-message body))]
                 [_ #f]))
        (error <twitter-api-error>
               :status status :headers headers :body body
               body))))

;; select body elements text
(define (parse-html-message body)
  (let loop ((lines (string-split body "\n"))
			 (ret '()))
	(cond
     ((null? lines)
      (string-join (reverse ret) " "))
	 ((#/<h[0-9]>([^<]+)<\/h[0-9]>/ (car lines)) =>
	  (lambda (m) 
        (loop (cdr lines) (cons (m 1) ret))))
     (else
      (loop (cdr lines) ret)))))

(define (retrieve-stream getter f . args)
  (let loop ((cursor "-1") (ids '()))
    (let* ([r (apply f (append args (list :cursor cursor)))]
           [next ((if-car-sxpath '(// next_cursor *text*)) r)]
           [ids (cons (getter r) ids)])
      (if (equal? next "0")
        (concatenate (reverse ids))
        (loop next ids)))))
