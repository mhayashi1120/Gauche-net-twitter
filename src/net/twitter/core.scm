(define-module net.twitter.core
  (use gauche.parameter)
  (use net.oauth)
  (export
   <twitter-cred> <twitter-api-error> <twitter-timeout-error>
   twitter-use-https
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

(define-condition-type <twitter-timeout-error> <error> #f
  )

