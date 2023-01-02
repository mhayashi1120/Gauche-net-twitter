;; This module is deprecated. Whole procedure not working now. (2023-01-02)

(define-module net.twitter.dm
  (extend net.twitter.base)
  (use net.twitter.core)
  (export
   show/json
   list/json
   sent/json
   new/json send/json
   destroy/json
   ))
(select-module net.twitter.dm)

;;;
;;; JSON api
;;;

(define (show/json cred id . _keys)
  (call/oauth->json cred 'get #"/1.1/direct_messages/show"
                    (api-params _keys id)))

(define (list/json cred :key (count #f) (max-id #f) (since-id #f)
                   (skip-status #f) (include-entities #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/direct_messages"
                    (api-params _keys count max-id since-id
                                include-entities skip-status)))

(define (sent/json cred :key
                   (count #f) (page #f)
                   (max-id #f) (since-id #f)
                   (include-entities #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/direct_messages/sent"
                    (api-params _keys count page max-id since-id
                                include-entities)))

;; Deprecated
(define (new/json cred text id :key (screen-name #f) (user-id #f)
                  :allow-other-keys _keys)
  (apply send/json cred text :id id :screen-name screen-name :user-id user-id _keys))

(define (send/json cred text :key (screen-name #f) (user-id #f)
                  :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/direct_messages/new"
                    (api-params _keys text user-id screen-name)))

(define (destroy/json cred id :key (include-entities #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/direct_messages/destroy"
                    (api-params _keys id include-entities)))
