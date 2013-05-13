(define-module net.twitter.saved-search
  (use net.twitter.core)
  (export
   list/json
   show/json
   create/json
   destroy/json
   ))
(select-module net.twitter.saved-search)

;;;
;;; JSON api
;;;

(define (list/json cred . _keys)
  (call/oauth->json cred 'get #`"/1.1/saved_searches/list"
                    (api-params _keys)))

(define (show/json cred id . _keys)
  (call/oauth->json cred 'get #`"/1.1/saved_searches/show/,|id|"
                    (api-params _keys)))

(define (create/json cred query . _keys)
  (call/oauth->json cred 'post #`"/1.1/saved_searches/create"
					(api-params _keys query)))

(define (destroy/json cred id . _keys)
  (call/oauth->json cred 'post #`"/1.1/saved_searches/destroy/,|id|"
                    (api-params _keys)))

