;;;
;;; Twitter access module
;;;

(define-module net.twitter
  (use rfc.http)
  (use rfc.sha)
  (use rfc.hmac)
  (use rfc.base64)
  (use srfi-13)
  (use www.cgi)
  (use math.mt-random)
  (use gauche.uvector)
  (export twitter-init
	  twitter-post))
(select-module net.twitter)

;; =================
;; === Functions ===
;; =================

;; rfc.uri's uri-encode uses lower-case hex letters, but twitter requires
;; upper cases.   So we roll our own.
(define (uri-encode-string str)
  (call-with-string-io str
    (lambda(in out)
      (while (read-byte in) (.$ not eof-object?) => ch
        (if (char-set-contains? #[a-zA-Z0-9.~_-] (integer->char ch))
          (write-char (integer->char ch) out)
          (format out "%~2,'0X" ch))))))

(define (time-stamp) (number->string (sys-time)))

(define (random-string)
  (let ([random-source (make <mersenne-twister>
                         :seed (* (sys-time) (sys-getpid)))]
        [v (make-u32vector 10)])
    (mt-random-fill-u32vector! random-source v)
    (digest-hexify (sha1-digest-string (x->string v)))))

(define (query-compose query)
  (string-join (map (cut string-join <> "=") query) "&"))

(define (signature method uri info consumer-secret :optional (token-secret ""))
  (let* ((query-string (query-compose info))
         (signature-basic-string
          (string-append method "&"
                         (uri-encode-string uri) "&"
                         (uri-encode-string query-string))))
    (uri-encode-string
     (base64-encode-string
      (hmac-digest-string signature-basic-string
                          :key #`",|consumer-secret|&,|token-secret|"
                          :hasher <sha1>)))))

;; ==================
;; === Interfaces ===
;; ==================
(define (twitter-init consumer-key consumer-secret
                      :optional (input-callback default-input-callback))
  (let* ((r-query `(("oauth_consumer_key" ,consumer-key)
		    ("oauth_nonce" ,(random-string))
		    ("oauth_signature_method" "HMAC-SHA1")
		    ("oauth_timestamp" ,(time-stamp))
		    ("oauth_version" "1.0")))
	 (r-s (signature "POST"
			 "http://api.twitter.com/oauth/request_token"
			 r-query
			 consumer-secret))
	 (r-token (receive (status header body)
		      (http-post "api.twitter.com"
				 "/oauth/request_token"
				 (query-compose
				  `(,@r-query ("oauth_signature" ,r-s))))
		    (cgi-parse-parameters :query-string body)))
	 (request-token (cadr
			 (assoc "oauth_token" r-token)))
	 (request-token-secret (cadr
				(assoc "oauth_token_secret" r-token))))
    (if-let1 oauth-verifier
        (input-callback
         #`"https://api.twitter.com/oauth/authorize?oauth_token=,request-token")
      (let* ((a-query `(("oauth_consumer_key" ,consumer-key)
                        ("oauth_nonce" ,(random-string))
                        ("oauth_signature_method" "HMAC-SHA1")
                        ("oauth_timestamp" ,(time-stamp))
                        ("oauth_token" ,request-token)
                        ("oauth_verifier" ,oauth-verifier)))
             (a-s (signature "GET"
                             "http://api.twitter.com/oauth/access_token"
                             a-query
                             request-token-secret))
             (token (receive (status header body)
                        (http-post "api.twitter.com"
                                   "/oauth/access_token"
                                   (query-compose
                                    `(,@a-query ("oauth_signature" ,a-s))))
                      (cgi-parse-parameters :query-string body)))
             (access-token (cgi-get-parameter "oauth_token" token))
             (access-token-secret (cgi-get-parameter "oauth_token_secret" token)))
        (print "         Consumer Key: " consumer-key)
        (print "  Consumer Secret Key: " consumer-secret)
        (print "         Access Token: " access-token)
        (print "  Access Token Secret: " access-token-secret))
      (print "twitter-init aborted."))))

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
  (let* ((query `(("oauth_consumer_key" ,consumer-key)
		  ("oauth_nonce" ,(random-string))
		  ("oauth_signature_method" "HMAC-SHA1")
		  ("oauth_timestamp" ,(time-stamp))
		  ("oauth_token" ,access-token)))
	 (s (signature "POST"
		       "http://api.twitter.com/statuses/update.json"
		       `(,@query ,`("status"
				    ,(uri-encode-string message)))
		       consumer-secret
		       access-token-secret)))
    (http-post "api.twitter.com"
	       "/statuses/update.json"
	       (format "status=~A" (uri-encode-string message))
	       :Authorization (format "OAuth ~A"
				      (string-join
				       (map (cut string-join <> "=")
					    `(,@query ("oauth_signature" ,s))) ", ")))))

