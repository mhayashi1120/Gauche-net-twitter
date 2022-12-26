(define-module net.twitter.help
  (extend net.twitter.base)
  (use net.twitter.core)
  (export
   configuration/json
   languages/json
   rate-limit-status/json
   tos/json
   privacy/json))
(select-module net.twitter.help)

;;;
;;; JSON api
;;;

(define (configuration/json cred . _keys)
  (call/oauth->json cred 'get "/1.1/help/configuration"
                    (api-params _keys)))

(define (languages/json cred . _keys)
  (call/oauth->json cred 'get "/1.1/help/languages"
                    (api-params _keys)))

(define (rate-limit-status/json cred :key (resources #f)
                                :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/application/rate_limit_status"
                    (api-params _keys resources)))

(define (tos/json cred . _keys)
  (call/oauth->json cred 'get "/1.1/help/tos"
                    (api-params _keys)))

(define (privacy/json cred . _keys)
  (call/oauth->json cred 'get "/1.1/help/privacy"
                    (api-params _keys)))

