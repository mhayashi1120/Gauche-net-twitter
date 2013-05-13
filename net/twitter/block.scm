(define-module net.twitter.block
  (use net.twitter.core)
  (export
   ids/json
   list/json
   create/json
   destroy/json

   exists?
   ids
   ))
(select-module net.twitter.block)

;;;
;;; JSON api
;;;

;;
;; Block methods
;;

(define (list/json cred :key  (include-entities #f)
                   (skip-status #f) (cursor #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/blocks/list"
                    (api-params _keys cursor include-entities
                                skip-status)))

(define (ids/json cred :key (stringify-ids #f) (cursor #f)
                  :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/blocks/ids"
                    (api-params _keys stringify-ids)))

(define (create/json cred :key (id #f) (user-id #f) (screen-name #f)
                     (include-entities #f) (skip-status #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/blocks/create"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (destroy/json cred :key (id #f) (user-id #f) (screen-name #f)
                      (include-entities #f) (skip-status #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/blocks/destroy"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

;;;
;;; Utilities
;;;

(define (exists? cred user-id)
  (boolean (memq user-id (ids cred))))

(define (ids cred . args)
  (vector->list
   (assoc-ref
    (values-ref (apply ids/json cred args) 0)
    "ids")))

