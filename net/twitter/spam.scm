(define-module net.twitter.spam
  (use net.twitter.core)
  (export
   report-spam/sxml report-spam/json))
(select-module net.twitter.spam)

;;;
;;; XML api
;;;

(define (report-spam/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                          :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/report_spam"
                    (api-params _keys id user-id screen-name)))

;;;
;;; JSON api
;;;

(define (report-spam/json cred :key (id #f) (user-id #f) (screen-name #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/report_spam"
                    (api-params _keys id user-id screen-name)))

