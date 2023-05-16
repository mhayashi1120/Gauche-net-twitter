;;;
;;; net.twitter.cursor.friendship
;;;
(define-module net.twitter.cursor.friendship
  (use net.twitter.friendship)
  (use net.twitter.cursor)
  (export
   friends/ids
   followers/ids))
(select-module net.twitter.cursor.friendship)

(define (%stream-ids/json f . args)
  (apply retrieve-stream (^x (vector->list (assoc-ref x "ids"))) f args))

;; ## Utility procedure get <lseq>
;; -> (ID:<integer> ...)
(define (friends/ids cred :key (id #f) (user-id #f)
                     (screen-name #f)
                     :allow-other-keys _keys)
  (apply %stream-ids/json friends/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))

;; ## Utility procedure
;; -> (ID:<integer> ...)
(define (followers/ids cred :key (id #f) (user-id #f)
                       (screen-name #f)
                       :allow-other-keys _keys)
  (apply %stream-ids/json followers/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))
