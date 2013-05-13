(define-module net.twitter.legal
  (use net.twitter.core)
  (use srfi-1)
  (export
   legal-tos/json legal-privacy/json))
(select-module net.twitter.legal)

;;;
;;; JSON api
;;;

(define (legal-tos/json cred :key (lang #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/legal/tos"
                    (api-params _keys lang)))

(define (legal-privacy/json cred :key (lang #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/legal/privacy"
                    (api-params _keys lang)))

