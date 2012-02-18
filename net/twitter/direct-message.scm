(define-module net.twitter.direct-message
  (use net.twitter.core)
  (use util.list)
  (use sxml.sxpath)
  (export
   direct-messages/sxml
   direct-messages-sent/sxml
   direct-message-new/sxml
   direct-message-destroy/sxml
   ))
(select-module net.twitter.direct-message)

(define (direct-messages/sxml cred :key (count #f) (page #f) (max_id #f) (since-id #f))
  (call/oauth->sxml cred 'get #`"/1/direct_messages.xml"
                    (make-query-params count page max_id since-id)))

(define (direct-messages-sent/sxml cred :key
                                   (count #f) (page #f) 
                                   (max_id #f) (since-id #f))
  (call/oauth->sxml cred 'get #`"/1/direct_messages/sent.xml"
                    (make-query-params count page max_id since-id)))

(define (direct-message-new/sxml cred user text)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/new.xml"
                    (make-query-params user text)))

(define (direct-message-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/destroy.xml"
                    (make-query-params id)))


