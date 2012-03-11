(define-module net.twitter.notification
  (use net.twitter.core)
  (use util.list)
  (export
   notifications-follow/sxml
   notifications-leave/sxml))
(select-module net.twitter.notification)

(define (notifications-follow/sxml cred :key
                                   (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/follow.xml"
                    (make-query-params id user-id screen-name)))

(define (notifications-leave/sxml cred :key
                                  (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/leave.xml"
                    (make-query-params id user-id screen-name)))
