(define-module net.twitter.favorite
  (use net.twitter.core)
  (use util.list)

  (export
   favorites/sxml
   favorite-create/sxml
   favorite-destroy/sxml))
(select-module net.twitter.favorite)

(define (favorites/sxml cred id :key (count #f) (since-id #f) (max-id #f)
                        (page #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/favorites.xml"
                    (query-params id count since-id max-id page
                                  include-entities)))

(define (favorite-create/sxml cred id :key (include-entities #f))
  (call/oauth->sxml cred 'post #`"/1/favorites/create/,|id|.xml"
                    (query-params include-entities)))

(define (favorite-destroy/sxml cred id :key)
  (call/oauth->sxml cred 'post #`"/1/favorites/destroy/,|id|.xml"
                    (query-params)))

