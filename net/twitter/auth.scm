(define-module net.twitter.auth
  (extend net.twitter.base)
  (use net.oauth)
  (use net.twitter.core)
  (use srfi-13)

  (export
   twitter-authenticate-client
   twitter-authenticate-request
   twitter-authorize))
(select-module net.twitter.auth)

;;
;; OAuth authorization flow
;;

(define (default-authenticate-callback temp-cred)
  (let1 url (twitter-authorize-url temp-cred)
    (print "Open the following url and type in the shown PIN.")
    (print url)
    (let loop ()
      (display "Input PIN: ") (flush)
      (let1 pin (read-line)
        (cond [(eof-object? pin) #f]
              [(string-null? pin) (loop)]
              [else pin])))))

(define twitter-authenticate-request
  (oauth-temporary-credential
   (build-url "api.twitter.com" "/oauth/request_token")
   :class <twitter-cred>))

(define twitter-authorize-url
  (oauth-authorize-constructor
   (build-url "api.twitter.com" "/oauth/authorize")))

(define twitter-authorize
  (oauth-credential
   (build-url "api.twitter.com" "/oauth/access_token")
   :class <twitter-cred>))

;; Authenticate the client using OAuth PIN-based authentication flow.
(define (twitter-authenticate-client key secret)
  (and-let* ((temp (twitter-authenticate-request key secret))
             (verifier (default-authenticate-callback temp)))
    (twitter-authorize temp verifier)))

