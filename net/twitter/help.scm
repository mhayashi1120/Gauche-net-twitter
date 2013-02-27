(define-module net.twitter.help
  (use net.twitter.core)
  (export
   help-configuration/json
   help-languages/json
   help-rate-limit-status/json
   help-tos/json
   help-privacy/json))
(select-module net.twitter.help)

;;;
;;; JSON api
;;;

(define (help-configuration/json cred)
  (call/oauth->json cred 'get "/1.1/help/configuration" '()))

(define (help-languages/json cred)
  (call/oauth->json cred 'get "/1.1/help/languages" '()))

(define (help-rate-limit-status/json cred)
  (call/oauth->json cred 'get #`"/1.1/application/rate_limit_status" '()))

(define (help-tos/json cred :key (lang #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/help/tos"
                    (api-params _keys lang)))

(define (help-privacy/json cred :key (lang #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/help/privacy"
                    (api-params _keys lang)))

