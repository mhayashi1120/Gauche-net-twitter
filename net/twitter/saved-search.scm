(define-module net.twitter.saved-search
  (use net.twitter.core)
  (export
   saved-searches/sxml
   saved-search-show/sxml
   saved-search-create/sxml
   saved-search-destroy/sxml

   saved-searches/json
   saved-search-show/json
   saved-search-create/json
   saved-search-destroy/json
   ))
(select-module net.twitter.saved-search)

;;;
;;; XML api
;;;

(define (saved-searches/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/saved_searches" '()))

(define (saved-search-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/saved_searches/show/,|id|" '()))

(define (saved-search-create/sxml cred query)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/create"
					(api-params '() query)))

(define (saved-search-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/destroy/,|id|" '()))


;;;
;;; JSON api
;;;

(define (saved-searches/json cred)
  (call/oauth->json cred 'get #`"/1/saved_searches" '()))

(define (saved-search-show/json cred id)
  (call/oauth->json cred 'get #`"/1/saved_searches/show/,|id|" '()))

(define (saved-search-create/json cred query)
  (call/oauth->json cred 'post #`"/1/saved_searches/create"
					(api-params '() query)))

(define (saved-search-destroy/json cred id)
  (call/oauth->json cred 'post #`"/1/saved_searches/destroy/,|id|" '()))

