(define-module net.twitter.favorite
  (use net.twitter.core)

  (export
   favorites/sxml
   favorite-create/sxml
   favorite-destroy/sxml

   favorites/json
   favorite-create/json
   favorite-destroy/json))

(select-module net.twitter.favorite)

;;;
;;; XML api
;;;

(define (favorites/sxml cred id :key (count #f) (since-id #f) (max-id #f)
                        (page #f) (include-entities #f)
                        :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/favorites"
                    (api-params _keys
                                id count since-id max-id page
                                include-entities)))

(define (favorite-create/sxml cred id :key (include-entities #f)
                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/favorites/create/,|id|"
                    (api-params _keys include-entities)))

(define (favorite-destroy/sxml cred id :key (_dummy #f) :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/favorites/destroy/,|id|"
                    (api-params _keys)))


;;;
;;; JSON api
;;;

(define (favorites/json cred id :key (count #f) (since-id #f) (max-id #f)
                        (page #f) (include-entities #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/favorites"
                    (api-params _keys
                                id count since-id max-id page
                                include-entities)))

(define (favorite-create/json cred id :key (include-entities #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/favorites/create/,|id|"
                    (api-params _keys include-entities)))

(define (favorite-destroy/json cred id :key (_dummy #f) :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/favorites/destroy/,|id|"
                    (api-params _keys)))

