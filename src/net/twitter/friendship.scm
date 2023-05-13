(define-module net.twitter.friendship
  (extend net.twitter.base)
  (use net.twitter.core)
  (export
   show/json
   create/json
   destroy/json
   update/json
   friends/ids/json
   friends/list/json
   followers/ids/json
   followers/list/json

   friends-outgoing/json
   friends-incoming/json
   friends-no-retweets/ids/json
   friends-lookup/json

   friends/ids
   followers/ids
   ))
(select-module net.twitter.friendship)

;;;
;;; JSON api
;;;

(define (friends/ids/json cred :key (id #f) (user-id #f)
                          (screen-name #f) (count #f)
                          (cursor #f) (stringify-ids #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friends/ids"
                    (api-params _keys id user-id screen-name cursor
                                count stringify-ids)))

(define (friends/list/json cred :key (include-user-entities #f) (skip-status #f)
                           (cursor #f) (screen-name #f) (user-id #f) (count #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friends/list"
                    (api-params _keys include-user-entities skip-status
                                cursor screen-name user-id)))

(define (followers/ids/json cred :key (id #f) (user-id #f)
                            (screen-name #f) (count #f)
                            (cursor #f) (stringify-ids #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/followers/ids"
                    (api-params _keys id user-id screen-name cursor
                                count stringify-ids)))

(define (followers/list/json cred :key (include-user-entities #f) (skip-status #f)
                             (cursor #f) (screen-name #f) (user-id #f) (count #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/followers/list"
                    (api-params _keys include-user-entities skip-status
                                cursor screen-name user-id)))

(define (show/json cred :key (source-id #f) (source-screen-name #f)
                   (target-id #f) (target-screen-name #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/friendships/show"
                    (api-params _keys source-id source-screen-name
                                target-id target-screen-name)))

(define (create/json cred :key (id #f) (user-id #f) (screen-name #f)
                     (follow #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/friendships/create"
                    (api-params _keys id user-id screen-name
                                follow)))

(define (destroy/json cred :key (id #f) (user-id #f) (screen-name #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/friendships/destroy"
                    (api-params _keys id user-id screen-name)))

(define (update/json cred :key (device #f)
                     (retweets #f) (screen-name #f) (user-id #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/friendships/update"
                    (api-params _keys screen-name device retweets user-id)))

(define (friends-outgoing/json cred :key (cursor #f) (stringify-ids #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friendships/outgoing"
                    (api-params _keys count stringify-ids)))

(define (friends-no-retweets/ids/json cred :key (stringify-ids #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friendships/no_retweets/ids"
                    (api-params _keys count stringify-ids)))

(define (friends-lookup/json cred :key (id #f) (user-id #f) (screen-name #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friendships/lookup"
                    (api-params _keys id user-id count)))

(define (friends-incoming/json cred :key (cursor #f) (stringify-ids #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/friendships/incoming"
                    (api-params _keys cursor count stringify-ids)))

;;;
;;; Utilities
;;;

(define (%stream-ids/json f . args)
  (apply retrieve-stream (^x (vector->list (assoc-ref x "ids"))) f args))

;; -> (ID:<integer> ...)
(define (friends/ids cred :key (id #f) (user-id #f)
                     (screen-name #f)
                     :allow-other-keys _keys)
  (apply %stream-ids/json friends/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))

;; -> (ID:<integer> ...)
(define (followers/ids cred :key (id #f) (user-id #f)
                       (screen-name #f)
                       :allow-other-keys _keys)
  (apply %stream-ids/json followers/ids/json
         cred :id id :user-id user-id
         :screen-name screen-name
         _keys))
