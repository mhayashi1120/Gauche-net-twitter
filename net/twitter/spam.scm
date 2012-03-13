(define-module net.twitter.spam
  (use net.twitter.core)
  (export
   report-spam/sxml))
(select-module net.twitter.spam)

(define (report-spam/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/report_spam.xml"
                    (query-params id user-id screen-name)))


