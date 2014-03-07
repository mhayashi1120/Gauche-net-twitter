(define-module net.twitter.favorite
  (extend net.twitter.base)
  (use net.twitter.core)

  (export
   list/json
   create/json
   destroy/json))

(select-module net.twitter.favorite)

;;;
;;; JSON api
;;;

(define (list/json cred id :key (count #f) (since-id #f) (max-id #f)
                   (include-entities #f) (screen-name #f) (user-id #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/favorites/list"
                    (api-params _keys
                                id count since-id max-id
                                include-entities screen-name user-id)))

(define (create/json cred id :key (include-entities #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/favorites/create"
                    (api-params _keys id include-entities)))

(define (destroy/json cred id :key (include-entities #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/favorites/destroy"
                    (api-params _keys id include-entities)))

