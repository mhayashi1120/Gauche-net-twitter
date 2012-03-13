(define-module net.twitter.notification
  (use net.twitter.core)
  (export
   notifications-follow/sxml
   notifications-leave/sxml))
(select-module net.twitter.notification)

(define (notifications-follow/sxml cred :key
                                   (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/follow.xml"
                    (query-params id user-id screen-name)))

(define (notifications-leave/sxml cred :key
                                  (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/leave.xml"
                    (query-params id user-id screen-name)))
