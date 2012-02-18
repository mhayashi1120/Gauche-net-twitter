(define-module net.twitter.help
  (use net.twitter.core)
  (export
   help-test/sxml
   help-configuration/sxml
   help-languages/sxml))
(select-module net.twitter.help)

(define (help-test/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/test.xml" '()))

(define (help-configuration/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/configuration.xml" '()))

(define (help-languages/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/languages.xml" '()))
