(define-module net.twitter.help
  (use net.twitter.core)
  (export
   help-test/sxml
   help-configuration/sxml
   help-languages/sxml

   help-test/json
   help-configuration/json
   help-languages/json))
(select-module net.twitter.help)

;;;
;;; XML api
;;;

(define (help-test/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/test" '()))

(define (help-configuration/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/configuration" '()))

(define (help-languages/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/languages" '()))


;;;
;;; JSON api
;;;

(define (help-test/json cred)
  (call/oauth->json cred 'get "/1/help/test" '()))

(define (help-configuration/json cred)
  (call/oauth->json cred 'get "/1/help/configuration" '()))

(define (help-languages/json cred)
  (call/oauth->json cred 'get "/1/help/languages" '()))
