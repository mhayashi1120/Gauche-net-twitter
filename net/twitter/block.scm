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
   ))
(select-module net.twitter.block)

;;
;; Block methods
;;

(define (blocks/sxml cred :key (page #f)
                     (per-page #f) (include-entities #f)
                     (skip-status #f)
                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking.xml"
                    (api-params _keys page
                                per-page include-entities
                                skip-status)))

(define (blocks/ids/sxml cred :key (stringfy-ids #f)
                         :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking/ids.xml"
                    (api-params _keys stringfy-ids)))

(define (block-create/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                           (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/blocks/create.xml"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-destroy/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                            (include-entities #f) (skip-status #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/blocks/destroy.xml"
                    (api-params _keys id user-id screen-name
                                include-entities skip-status)))

(define (block-exists/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/blocks/exists.xml"
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

