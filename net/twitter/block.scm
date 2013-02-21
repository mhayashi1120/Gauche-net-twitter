(define-module net.twitter.block
  (use net.twitter.core)
  (use sxml.sxpath)
  (export
   blocks/sxml
   blocks/ids/sxml
   block-create/sxml
   block-destroy/sxml
   block-exists/sxml
   block-exists?
   blocks/ids

   blocks/json
   blocks/ids/json
   block-create/json
   block-destroy/json
   block-exists/json
   ))
(select-module net.twitter.block)

;;;
;;; XML api
;;;

;;
;; Block methods
;;

(define (blocks/sxml cred :key (page #f)
                     (per-page #f) (include-entities #f)
                     (skip-status #f)
                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking"
                    (api-params _keys page
                                per-page include-entities
                                skip-status)))

(define (blocks/ids/sxml cred :key (stringfy-ids #f)
                         :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking/ids"
                    (api-params _keys stringfy-ids)))

(define (block-create/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                           (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/blocks/create"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-destroy/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                            (include-entities #f) (skip-status #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/blocks/destroy"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-exists/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/exists"
                    (api-params _keys id user-id screen-name)))

(define (block-exists? . args)
  (guard (e
          ((<twitter-api-error> e)
           ;;FIXME this message is not published API
           (if (string=? (ref e 'message) "You are not blocking this user.")
             #f
             (raise e))))
    (apply block-exists/sxml args)
    #t))

(define (blocks/ids cred . args)
  ((sxpath '(// id *text*)) (apply blocks/ids/sxml cred args)))


;;;
;;; JSON api
;;;

;;
;; Block methods
;;

(define (blocks/json cred :key (page #f)
                     (per-page #f) (include-entities #f)
                     (skip-status #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/blocks/blocking"
                    (api-params _keys page
                                per-page include-entities
                                skip-status)))

(define (blocks/ids/json cred :key (stringfy-ids #f)
                         :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/blocks/blocking/ids"
                    (api-params _keys stringfy-ids)))

(define (block-create/json cred :key (id #f) (user-id #f) (screen-name #f)
                           (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/blocks/create"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-destroy/json cred :key (id #f) (user-id #f) (screen-name #f)
                            (include-entities #f) (skip-status #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/blocks/destroy"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-exists/json cred :key (id #f) (user-id #f) (screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/blocks/exists"
                    (api-params _keys id user-id screen-name)))

