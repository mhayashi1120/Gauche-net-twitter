(define-module net.twitter.saved-search
  (use net.twitter.core)
  (use util.list)
  (use sxml.sxpath)
  (export
   saved-searches/sxml
   saved-search-show/sxml
   saved-search-create/sxml
   saved-search-destroy/sxml
   ))
(select-module net.twitter.saved-search)

(define (saved-searches/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/saved_searches.xml" '()))

(define (saved-search-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/saved_searches/show/,|id|.xml" '()))

(define (saved-search-create/sxml cred query)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/create.xml" 
					(query-params query)))

(define (saved-search-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/destroy/,|id|.xml" '()))

