(define-module net.twitter.help
  (use net.twitter.core)
  (export
   help-test/json
   help-configuration/json
   help-languages/json))
(select-module net.twitter.help)

;;;
;;; JSON api
;;;

(define (help-test/json cred)
  (call/oauth->json cred 'get "/1.1/help/test" '()))

(define (help-configuration/json cred)
  (call/oauth->json cred 'get "/1.1/help/configuration" '()))

(define (help-languages/json cred)
  (call/oauth->json cred 'get "/1.1/help/languages" '()))

(define (help-rate-limit-status/json cred)
  (call/oauth->json cred 'get #`"/1.1/application/rate_limit_status" '()))

