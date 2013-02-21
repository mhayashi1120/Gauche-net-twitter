(define-module net.twitter.direct-message
  (use net.twitter.core)
  (export
   direct-message-show/sxml
   direct-messages/sxml
   direct-messages-sent/sxml
   direct-message-new/sxml
   direct-message-destroy/sxml

   direct-message-show/json
   direct-messages/json
   direct-messages-sent/json
   direct-message-new/json
   direct-message-destroy/json
   ))
(select-module net.twitter.direct-message)

;;;
;;; XML api
;;;

(define (direct-message-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/direct_messages/show/,|id|"
                    '()))

(define (direct-messages/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/direct_messages"
                    (api-params _keys count page max-id since-id)))

(define (direct-messages-sent/sxml cred :key
                                   (count #f) (page #f)
                                   (max-id #f) (since-id #f)
                                   (include-entities #f)
                                   :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/direct_messages/sent"
                    (api-params _keys count page max-id since-id
                                include-entities)))

(define (direct-message-new/sxml cred user text :key (user-id #f) (screen-name #f)
                                 (wrap-links #f)
                                 :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/new"
                    (api-params _keys user text user-id screen-name wrap-links)))

(define (direct-message-destroy/sxml cred id :key (include-entities #f)
                                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/destroy"
                    (api-params _keys id include-entities)))



;;;
;;; JSON api
;;;

(define (direct-message-show/json cred id)
  (call/oauth->json cred 'get #`"/1/direct_messages/show/,|id|"
                    '()))

(define (direct-messages/json cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/direct_messages"
                    (api-params _keys count page max-id since-id)))

(define (direct-messages-sent/json cred :key
                                   (count #f) (page #f)
                                   (max-id #f) (since-id #f)
                                   (include-entities #f)
                                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/direct_messages/sent"
                    (api-params _keys count page max-id since-id
                                include-entities)))

(define (direct-message-new/json cred user text :key (user-id #f) (screen-name #f)
                                 (wrap-links #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/direct_messages/new"
                    (api-params _keys user text user-id screen-name wrap-links)))

(define (direct-message-destroy/json cred id :key (include-entities #f)
                                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/direct_messages/destroy"
                    (api-params _keys id include-entities)))


