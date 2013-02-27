(define-module net.twitter.friendship
  (use net.twitter.core)
  (export
   friendship-show/json
   friendship-create/json
   friendship-destroy/json
   friendship-update/json
   friends/ids/json
   friends/list/json
   followers/ids/json
   followers/list/json

   friends/ids
   followers/ids
   ))
(select-module net.twitter.friendship)

;;;
;;; JSON api
;;;

(define (friends/ids/json cred :key (id #f) (user-id #f)
                          (screen-name #f)
                          (cursor #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friends/ids"
                    (api-params _keys id user-id screen-name cursor)))

(define (friends/list/json cred :key (_dummy #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friends/list"
                    (api-params _keys)))

(define (followers/ids/json cred :key (id #f) (user-id #f)
                            (screen-name #f)
                            (cursor #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/followers/ids"
                    (api-params _keys id user-id screen-name cursor)))

(define (followers/list/json cred :key (_dummy #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/followers/list"
                    (api-params _keys)))

(define (retrieve-ids/json f . args)
  (apply retrieve-stream (^x (vector->list (assoc-ref x "ids"))) f args))

(define (friendship-show/json cred :key (source-id #f) (source-screen-name #f)
                              (target-id #f) (target-screen-name #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/friendships/show"
                    (api-params _keys source-id source-screen-name
                                target-id target-screen-name)))

(define (friendship-create/json cred id :key (id #f) (user-id #f) (screen-name #f)
                                (follow #f)
                                :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/friendships/create"
                    (api-params _keys id user-id screen-name
                                follow)))

(define (friendship-destroy/json cred id :key (id #f) (user-id #f) (screen-name #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/friendships/destroy"
                    (api-params _keys id user-id screen-name)))

(define (friendship-update/json cred screen-name :key (device #f)
                                (retweets #f)
                                :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/friendships/update"
                    (api-params _keys screen-name device retweets)))

;;;
;;; Utilities
;;;

;; Returns list of user ids
(define (friends/ids cred :key (id #f) (user-id #f)
                     (screen-name #f)
                     :allow-other-keys _keys)
  (apply retrieve-ids/json friends/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))

;; Returns ids of *all* followers; paging is handled automatically.
(define (followers/ids cred :key (id #f) (user-id #f)
                       (screen-name #f)
                       :allow-other-keys _keys)
  (apply retrieve-ids/json followers/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))


