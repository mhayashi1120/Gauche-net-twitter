(define-module net.twitter.block
  (use net.twitter.core)
  (export
   blocks/ids/json
   blocks-list/json
   block-create/json
   block-destroy/json

   block-exists?
   blocks/ids
   ))
(select-module net.twitter.block)

;;;
;;; JSON api
;;;

;;
;; Block methods
;;

(define (blocks-list/json cred :key  (include-entities #f)
                          (skip-status #f) (cursor #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/blocks/list"
                    (api-params _keys cursor include-entities
                                skip-status)))

(define (blocks/ids/json cred :key (stringfy-ids #f)
                         :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/blocks/ids"
                    (api-params _keys stringfy-ids)))

(define (block-create/json cred :key (id #f) (user-id #f) (screen-name #f)
                           (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/blocks/create"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-destroy/json cred :key (id #f) (user-id #f) (screen-name #f)
                            (include-entities #f) (skip-status #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/blocks/destroy"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

;;;
;;; Utilities
;;;

(define (block-exists? cred user-id)
  (boolean (memq user-id (blocks/ids cred))))

(define (blocks/ids cred . args)
  (vector->list
   (assoc-ref
    (values-ref (apply blocks/ids/json cred args) 0)
    "ids")))

