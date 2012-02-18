(define-module net.twitter.legal
  (use net.twitter.core)
  (export
   legal-tos/sxml legal-privacy/sxml))
(select-module net.twitter.legal)

(define (legal-tos/sxml cred :key (lang #f))
  (call/oauth->sxml cred 'get "/1/legal/tos.xml" '()))

(define (legal-privacy/sxml cred :key (lang #f))
  (call/oauth->sxml cred 'get "/1/legal/privacy.xml" '()))

