(define-module net.twitter.notification
  (use net.twitter.core)
  (export
   notifications-follow/json
   notifications-leave/json))
(select-module net.twitter.notification)

;;;
;;; JSON api
;;;

(define (notifications-follow/json cred :key
                                   (id #f) (user-id #f) (screen-name #f)
                                   :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/notifications/follow"
                    (api-params _keys id user-id screen-name)))

(define (notifications-leave/json cred :key
                                  (id #f) (user-id #f) (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/notifications/leave"
                    (api-params _keys id user-id screen-name)))
