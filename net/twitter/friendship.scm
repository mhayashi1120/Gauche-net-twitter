(define-module net.twitter.friendship
  (use net.twitter.core)
  (use sxml.sxpath)
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

   friendship-show/json
   friendship-exists/json
   friendship-exists?
   friendship-create/json
   friendship-destroy/json
   friendship-update/json

   friends/ids/json
   followers/ids/json
   ))
(select-module net.twitter.friendship)

;;;
;;; XML api
;;;

(define (friends/ids/sxml cred :key (id #f) (user-id #f)
                          (screen-name #f)
                          (cursor #f)
                          :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/friends/ids"
                    (api-params _keys id user-id screen-name cursor)))

;; Returns list of user ids
(define (friends/ids cred :key (id #f) (user-id #f)
                     (screen-name #f)
                     :allow-other-keys _keys)
  (apply retrieve-ids/sxml friends/ids/sxml
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))

(define (followers/ids/sxml cred :key (id #f) (user-id #f)
                            (screen-name #f)
                            (cursor #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/followers/ids"
                    (api-params _keys id user-id screen-name cursor)))

;; Returns ids of *all* followers; paging is handled automatically.
(define (followers/ids cred :key (id #f) (user-id #f)
                       (screen-name #f)
                       :allow-other-keys _keys)
  (apply retrieve-ids/sxml followers/ids/sxml
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))

(define (retrieve-ids/sxml f . args)
  (apply retrieve-stream (sxpath '(// id *text*)) f args))


(define (friendship-show/sxml cred :key (source-id #f) (source-screen-name #f)
                              (target-id #f) (target-screen-name #f)
                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/friendships/show"
                    (api-params _keys source-id source-screen-name
                                target-id target-screen-name)))

(define (friendship-exists/sxml cred :key
                                (user-id-a #f) (user-id-b #f)
                                (screen-name-a #f) (screen-name-b #f)
                                :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/friendships/exists"
                    (api-params _keys
                     user-id-a user-id-b
                     screen-name-a screen-name-b)))

(define (friendship-exists? cred . args)
  (string=?
   ((if-car-sxpath '(friends *text*))
    (values-ref (apply friendship-exists/sxml cred args) 0))
   "true"))

(define (friendship-create/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/create/,|id|" '()))

(define (friendship-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/destroy/,|id|" '()))

;; for backward compatibility
(define-method friendship-incoming/sxml (cred (cursor <top>))
  (friendship-incoming/sxml cred :cursor cursor))

(define-method friendship-incoming/sxml (cred :key (cursor #f) (stringify-ids #f)
                                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/friendships/incoming"
                    (api-params _keys cursor stringify-ids)))

;; for backward compatibility
(define-method friendship-outgoing/sxml (cred (cursor <top>))
  (friendship-outgoing/sxml cred :cursor cursor))

(define-method friendship-outgoing/sxml (cred :key (cursor #f) (stringify-ids #f)
                                              :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/friendships/outgoing"
                    (api-params _keys cursor stringify-ids)))

(define (friendship-update/sxml cred screen-name :key (device #f)
                                (retweets #f)
                                :allow-other-keys _keys)
  (call/oauth->sxml cred 'post #`"/1/friendships/update"
                    (api-params _keys screen-name device retweets)))


;;;
;;; JSON api
;;;

(define (friends/ids/json cred :key (id #f) (user-id #f)
                          (screen-name #f)
                          (cursor #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/friends/ids"
                    (api-params _keys id user-id screen-name cursor)))

(define (followers/ids/json cred :key (id #f) (user-id #f)
                            (screen-name #f)
                            (cursor #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/followers/ids"
                    (api-params _keys id user-id screen-name cursor)))

(define (retrieve-ids/json f . args)
  (apply retrieve-stream (sxpath '(// id *text*)) f args))


(define (friendship-show/json cred :key (source-id #f) (source-screen-name #f)
                              (target-id #f) (target-screen-name #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/friendships/show"
                    (api-params _keys source-id source-screen-name
                                target-id target-screen-name)))

(define (friendship-exists/json cred :key
                                (user-id-a #f) (user-id-b #f)
                                (screen-name-a #f) (screen-name-b #f)
                                :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/friendships/exists"
                    (api-params _keys
                     user-id-a user-id-b
                     screen-name-a screen-name-b)))

(define (friendship-create/json cred id)
  (call/oauth->json cred 'post #`"/1/friendships/create/,|id|" '()))

(define (friendship-destroy/json cred id)
  (call/oauth->json cred 'post #`"/1/friendships/destroy/,|id|" '()))

(define (friendship-update/json cred screen-name :key (device #f)
                                (retweets #f)
                                :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1/friendships/update"
                    (api-params _keys screen-name device retweets)))


