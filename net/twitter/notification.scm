(define-module net.twitter.notification
  (use net.twitter.core)
  (export
   notifications-follow/sxml
   notifications-leave/sxml))
(select-module net.twitter.notification)

(define (notifications-follow/sxml cred :key
                                   (id #f) (user-id #f) (screen-name #f)
                                   :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/notifications/follow.xml"
                    (api-params _keys id user-id screen-name)))

(define (notifications-leave/sxml cred :key
                                  (id #f) (user-id #f) (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/notifications/leave.xml"
                    (api-params _keys id user-id screen-name)))
