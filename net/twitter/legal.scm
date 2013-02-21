(define-module net.twitter.legal
  (use net.twitter.core)
  (use srfi-1)
  (export
   legal-tos/sxml legal-privacy/sxml

   legal-tos/json legal-privacy/json))
(select-module net.twitter.legal)

;;;
;;; XML api
;;;

(define (legal-tos/sxml cred :key (lang #f)
                        :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/legal/tos"
                    (api-params _keys lang)))

(define (legal-privacy/sxml cred :key (lang #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/legal/privacy"
                    (api-params _keys lang)))


;;;
;;; JSON api
;;;

(define (legal-tos/json cred :key (lang #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/legal/tos"
                    (api-params _keys lang)))

(define (legal-privacy/json cred :key (lang #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/legal/privacy"
                    (api-params _keys lang)))

