(define-module net.twitter.direct-message
  (use net.twitter.core)
  (export
   direct-message-show/sxml
   direct-messages/sxml
   direct-messages-sent/sxml
   direct-message-new/sxml
   direct-message-destroy/sxml
   ))
(select-module net.twitter.direct-message)

(define (direct-message-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/direct_messages/show/,|id|.xml"
                    '()))

(define (direct-messages/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/direct_messages.xml"
                    (api-params _keys count page max-id since-id)))

(define (direct-messages-sent/sxml cred :key
                                   (count #f) (page #f)
                                   (max-id #f) (since-id #f)
                                   (include-entities #f)
                                   :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/direct_messages/sent.xml"
                    (api-params _keys count page max-id since-id
                                include-entities)))

(define (direct-message-new/sxml cred user text :key (user-id #f) (screen-name #f)
                                 (wrap-links #f)
                                 :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/new.xml"
                    (api-params _keys user text user-id screen-name wrap-links)))

(define (direct-message-destroy/sxml cred id :key (include-entities #f)
                                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/destroy.xml"
                    (api-params _keys id include-entities)))


