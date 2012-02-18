(define-module net.twitter.friendship
  (use sxml.sxpath)
  (use net.twitter.core)
  (use util.list)
  (export
   friendship-show/sxml
   friendship-exists/sxml
   friendship-exists?
   friendship-create/sxml
   friendship-destroy/sxml
   friendship-update/sxml

   friends/ids/sxml
   friends/ids
   followers/ids/sxml
   followers/ids

   ;; TODO deprecated
   friendship-incoming/sxml
   friendship-outgoing/sxml
   ))
(select-module net.twitter.friendship)

(define (friends/ids/sxml cred :key (id #f) (user-id #f)
                                  (screen-name #f)
                                  (cursor #f))
  (call/oauth->sxml cred 'get "/1/friends/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns list of user ids
(define (friends/ids cred :key (id #f) (user-id #f)
                             (screen-name #f))
  (retrieve-ids/sxml friends/ids/sxml
                     cred :id id :user-id user-id
                     :screen-name screen-name))

(define (followers/ids/sxml cred :key (id #f) (user-id #f)
                                    (screen-name #f)
                                    (cursor #f))
  (call/oauth->sxml cred 'get "/1/followers/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns ids of *all* followers; paging is handled automatically.
(define (followers/ids cred :key (id #f) (user-id #f)
                               (screen-name #f))
  (retrieve-ids/sxml followers/ids/sxml
                     cred :id id :user-id user-id
                     :screen-name screen-name))

(define (retrieve-ids/sxml f . args)
  (apply retrieve-stream (sxpath '(// id *text*)) f args))


(define (friendship-show/sxml cred :key (source-id #f) (source-screen-name #f)
                              (target-id #f) (target-screen-name #f))
  (call/oauth->sxml cred 'get #`"/1/friendships/show.xml"
                    (make-query-params source-id source-screen-name
                                       target-id target-screen-name)))

(define (friendship-exists/sxml cred :key 
                                (user-id-a #f) (user-id-b #f)
                                (screen-name-a #f) (screen-name-b #f))
  (call/oauth->sxml cred 'get #`"/1/friendships/exists.xml"
                    (make-query-params 
                     user-id-a user-id-b
                     screen-name-a screen-name-b)))

(define (friendship-exists? cred . args)
  (string=?
   ((if-car-sxpath '(friends *text*))
    (values-ref (apply friendship-exists/sxml cred args) 0))
   "true"))

(define (friendship-create/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/create/,|id|.xml" '()))

(define (friendship-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/destroy/,|id|.xml" '()))

;; for backward compatibility
(define-method friendship-incoming/sxml (cred (cursor <top>))
  (friendship-incoming/sxml cred :cursor cursor))

(define-method friendship-incoming/sxml (cred :key (cursor #f) (stringify-ids #f))
  (call/oauth->sxml cred 'get #`"/1/friendships/incoming.xml"
                    (make-query-params cursor stringify-ids)))

;; for backward compatibility
(define-method friendship-outgoing/sxml (cred (cursor <top>))
  (friendship-outgoing/sxml cred :cursor cursor))

(define-method friendship-outgoing/sxml (cred :key (cursor #f) (stringify-ids #f))
  (call/oauth->sxml cred 'get #`"/1/friendships/outgoing.xml"
                    (make-query-params cursor stringify-ids)))

(define (friendship-update/sxml cred screen-name :key (device #f)
                                (retweets #f))
  (call/oauth->sxml cred 'post #`"/1/friendships/update.xml" 
                    (make-query-params screen-name device retweets)))


