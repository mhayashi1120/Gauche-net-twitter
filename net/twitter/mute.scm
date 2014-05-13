(define-module net.twitter.mute
  (extend net.twitter.base)
  (use net.twitter.core)
  (export
   list/json ids/json
   create/json destroy/json))
(select-module net.twitter.mute)

;;;
;;; JSON api
;;;

(define (list/json cred :key (include-entities #f)
                   (skip-status #f) (cursor #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/mutes/users/list"
                    (api-params _keys cursor include-entities
                                skip-status)))

(define (ids/json cred :key (cursor #f)
                  :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/mutes/users/ids"
                    (api-params _keys cursor)))

(define (create/json cred :key (screen-name #f) (user-id #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/mutes/users/create"
                    (api-params _keys user-id screen-name)))

(define (destroy/json cred :key (screen-name #f) (user-id #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/mutes/users/destroy"
                    (api-params _keys user-id screen-name)))

