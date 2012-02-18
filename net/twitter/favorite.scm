(define-module net.twitter.favorite
  (use net.twitter.core)
  (use util.list)

  (export 
   favorites/sxml
   favorite-create/sxml
   favorite-destroy/sxml))
(select-module net.twitter.favorite)

(define (favorites/sxml cred id :key (page #f)
                                (since-id #f) (include-entities #f)
                                (skip-status #f))
  (call/oauth->sxml cred 'get #`"/1/favorites.xml"
                    (make-query-params id page since-id
                                       include-entities skip-status)))

(define (favorite-create/sxml cred id :key (include-entities #f)
                                      (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/favorites/create/,|id|.xml" 
                    (make-query-params include-entities skip-status)))

(define (favorite-destroy/sxml cred id :key (include-entities #f)
                                       (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/favorites/destroy/,|id|.xml"
                    (make-query-params include-entities skip-status)))

