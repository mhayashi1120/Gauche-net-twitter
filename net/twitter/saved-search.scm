(define-module net.twitter.saved-search
  (use net.twitter.core)
  (export
   saved-searches/json
   saved-search-show/json
   saved-search-create/json
   saved-search-destroy/json
   ))
(select-module net.twitter.saved-search)

;;;
;;; JSON api
;;;

(define (saved-searches/json cred)
  (call/oauth->json cred 'get #`"/1.1/saved_searches/list" '()))

(define (saved-search-show/json cred id)
  (call/oauth->json cred 'get #`"/1.1/saved_searches/show/,|id|" '()))

(define (saved-search-create/json cred query)
  (call/oauth->json cred 'post #`"/1.1/saved_searches/create"
					(api-params '() query)))

(define (saved-search-destroy/json cred id)
  (call/oauth->json cred 'post #`"/1.1/saved_searches/destroy/,|id|" '()))

