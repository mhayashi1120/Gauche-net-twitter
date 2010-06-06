;;;
;;; Twitter access module
;;;

(define-module net.twitter
  (use rfc.http)
  (use rfc.sha)
  (use rfc.hmac)
  (use rfc.base64)
  (use rfc.uri)
  (use srfi-13)
  (use www.cgi)
  (use math.mt-random)
  (use gauche.uvector)
  (use gauche.version)
  (use text.tree)
  (use util.list)
  (export twitter-authenticate-client
	  twitter-post))
(select-module net.twitter)

;; OAuth related stuff.
;; These may be factored out into net.oauth module someday.
;; References to the section numbers refer to http://oauth.net/core/1.0/.

;; Returns query parameters with calculated "oauth_signature"
(define (oauth-add-signature method request-url params consumer-secret
                             :optional (token-secret ""))
  `(,@params
    ("oauth_signature" ,(oauth-signature method request-url params
                                         consumer-secret token-secret))))

;; Calculate signature.
(define (oauth-signature method request-url params consumer-secret
                         :optional (token-secret ""))
  (base64-encode-string
   (hmac-digest-string (oauth-signature-base-string method request-url params)
                       :key #`",|consumer-secret|&,|token-secret|"
                       :hasher <sha1>)))

;; Construct signature base string. (Section 9.1)
(define (oauth-signature-base-string method request-url params)
  (define (param-sorter a b)
    (or (string<? (car a) (car b))
        (and (string=? (car a) (car b))
             (string<? (cadr a) (cadr b)))))
  (string-append
   (string-upcase method) "&"
   (oauth-uri-encode (oauth-normalize-request-url request-url)) "&"
   (oauth-uri-encode (oauth-compose-query params))))

;; Oauth requires hex digits in %-encodings to be upper case (Section 5.1)
;; The following two routines should be used instead of uri-encode-string
;; and http-compose-query to conform that.
(define (oauth-uri-encode str)
  (%-fix (uri-encode-string str :encoding 'utf-8)))

(define (oauth-compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))


;; Normalize request url.  (Section 9.1.2)
(define (oauth-normalize-request-url url)
  (receive (scheme userinfo host port path query frag) (uri-parse url)
    (tree->string `(,(string-downcase scheme) "://"
                    ,(if userinfo `(,(string-downcase userinfo) "@") "")
                    ,(string-downcase host)
                    ,(if (or (not port)
                             (and (string-ci=? scheme "http")
                                  (equal? port "80"))
                             (and (string-ci=? scheme "https")
                                  (equal? port "443")))
                       ""
                       `(":" ,port))
                    ,path))))

;; Reqest either request token or access token.
(define (oauth-request method request-url params consumer-secret
                       :optional (token-secret ""))
  (define (add-sign meth)
    (oauth-add-signature meth request-url params consumer-secret token-secret))
  (receive (scheme specific) (uri-scheme&specific request-url)
    ;; https is supported since 0.9.1
    (define secure-opt
      (cond [(equal? scheme "http") '()]
            [(equal? scheme "https")
             (if (version>? (gauche-version) "0.9") `(:secure #t) '())]
            [else (error "oauth-request: unsupported scheme" scheme)]))
    (receive (auth path query frag) (uri-decompose-hierarchical specific)
      (receive (status header body)
          (cond [(equal? method "GET")
                 (apply http-get auth
                        #`",|path|?,(oauth-compose-query (add-sign \"GET\"))"
                        secure-opt)]
                [(equal? method "POST")
                 (apply http-post auth path
                        (oauth-compose-query (add-sign "POST"))
                        secure-opt)]
                [else (error "oauth-request: unsupported method" method)])
        (unless (equal? status "200")
          (errorf "oauth-request: service provider responded ~a: ~a"
                  status body))
        (cgi-parse-parameters :query-string body)))))

(define (timestamp) (number->string (sys-time)))

(define (random-string)
  (let ([random-source (make <mersenne-twister>
                         :seed (* (sys-time) (sys-getpid)))]
        [v (make-u32vector 10)])
    (mt-random-fill-u32vector! random-source v)
    (digest-hexify (sha1-digest-string (x->string v)))))

;;;
;;; Public API
;;;

;; Authenticate the client using OAuth PIN-based authentication flow.
(define (twitter-authenticate-client consumer-key consumer-secret
                                     :optional (input-callback
                                                default-input-callback))
  (let* ([r-response
          (oauth-request "GET" "http://api.twitter.com/oauth/request_token"
                         `(("oauth_consumer_key" ,consumer-key)
                           ("oauth_nonce" ,(random-string))
                           ("oauth_signature_method" "HMAC-SHA1")
                           ("oauth_timestamp" ,(timestamp))
                           ("oauth_version" "1.0"))
                         consumer-secret)]
	 [r-token  (cgi-get-parameter "oauth_token" r-response)]
	 [r-secret (cgi-get-parameter "oauth_token_secret" r-response)])
    (unless (and r-token r-secret)
      (error "failed to obtain request token"))
    (if-let1 oauth-verifier
        (input-callback
         #`"https://api.twitter.com/oauth/authorize?oauth_token=,r-token")
      (let* ([a-response
              (oauth-request "POST" "http://api.twitter.com/oauth/access_token"
                             `(("oauth_consumer_key" ,consumer-key)
                               ("oauth_nonce" ,(random-string))
                               ("oauth_signature_method" "HMAC-SHA1")
                               ("oauth_timestamp" ,(timestamp))
                               ("oauth_token" ,r-token)
                               ("oauth_verifier" ,oauth-verifier))
                             r-secret)]
             [a-token (cgi-get-parameter "oauth_token" a-response)]
             [a-secret (cgi-get-parameter "oauth_token_secret" a-response)])
        `(:consumer-key ,consumer-key
          :consumer-secret ,consumer-secret
          :access-token ,a-token
          :access-token-secret ,a-secret))
      #f)))

(define (default-input-callback url)
  (print "Open the following url and type in the shown PIN.")
  (print url)
  (let loop ()
    (display "Input PIN: ") (flush)
    (let1 pin (read-line)
      (cond [(eof-object? pin) #f]
            [(string-null? pin) (loop)]
            [else pin]))))

(define (twitter-post consumer-key consumer-secret
		      access-token access-token-secret
		      message)
  (let* ([auth-params `(("oauth_consumer_key" ,consumer-key)
                        ("oauth_nonce" ,(random-string))
                        ("oauth_signature_method" "HMAC-SHA1")
                        ("oauth_timestamp" ,(timestamp))
                        ("oauth_token" ,access-token))]
         [signature (oauth-signature
                     "POST" "http://api.twitter.com/statuses/update.json"
                     `(,@auth-params ("status" ,message))
                     consumer-secret
                     access-token-secret)]
         [auth-line
          (format "OAuth ~a"
                  (string-join (map (cut string-join <> "=")
                                    `(,@auth-params
                                      ("oauth_signature"
                                       ,(oauth-uri-encode signature))))
                               ", "))])
    (http-post "api.twitter.com"
               "/statuses/update.json"
               (oauth-compose-query `(("status" ,message)))
               :Authorization auth-line)))
