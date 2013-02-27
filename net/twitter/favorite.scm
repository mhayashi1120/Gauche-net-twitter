(define-module net.twitter.favorite
  (use net.twitter.core)

  (export
   favorites/json
   favorite-create/json
   favorite-destroy/json))

(select-module net.twitter.favorite)

;;;
;;; JSON api
;;;

(define (favorites/json cred id :key (count #f) (since-id #f) (max-id #f)
                        (page #f) (include-entities #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/favorites/list"
                    (api-params _keys
                                id count since-id max-id page
                                include-entities)))

(define (favorite-create/json cred id :key (include-entities #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/favorites/create"
                    (api-params _keys id include-entities)))

(define (favorite-destroy/json cred id :key (_dummy #f) :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/favorites/destroy"
                    (api-params _keys id)))

