(define-module net.twitter.dm
  (use net.twitter.core)
  (export
   show/json
   list/json
   sent/json
   new/json
   destroy/json
   ))
(select-module net.twitter.dm)

;;;
;;; JSON api
;;;

(define (show/json cred id :key (id #f) :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/direct_messages/show"
                    (api-params _keys id)))

(define (list/json cred :key (count #f) (max-id #f) (since-id #f)
                              (skip-status #f) (include-entities #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/direct_messages"
                    (api-params _keys count max-id since-id
                                include-entities skip-status)))

(define (sent/json cred :key
                                   (count #f) (page #f)
                                   (max-id #f) (since-id #f)
                                   (include-entities #f)
                                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/direct_messages/sent"
                    (api-params _keys count page max-id since-id
                                include-entities)))

(define (new/json cred text user-id :key (screen-name #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/direct_messages/new"
                    (api-params _keys text user-id screen-name)))

(define (destroy/json cred id :key (include-entities #f)
                                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/direct_messages/destroy"
                    (api-params _keys id include-entities)))


