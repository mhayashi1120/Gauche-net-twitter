(define-module net.twitter.legal
  (use net.twitter.core)
  (use srfi-1)
  (export
   legal-tos/sxml legal-privacy/sxml))
(select-module net.twitter.legal)

(define (legal-tos/sxml cred :key (lang #f)
                        :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/legal/tos.xml"
                    (api-params _keys lang)))

(define (legal-privacy/sxml cred :key (lang #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/legal/privacy.xml"
                    (api-params _keys lang)))

