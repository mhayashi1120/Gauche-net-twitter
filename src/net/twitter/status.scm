(define-module net.twitter.status
  (extend net.twitter.base)
  (use srfi-1)
  (use net.twitter.core)
  (export
   update
   show/json
   update/json
   update-with-media/json
   destroy/json
   retweet/json
   retweets/json
   oembed/json oembed
   retweeters/ids/json
   lookup/json
   ))
(select-module net.twitter.status)

;;;
;;; JSON api
;;;

;; cred can be #f to view public tweet.
(define (show/json cred id :key (include-entities #f) (trim-user #f)
                   (include-my-retweet #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/statuses/show"
					(api-params _keys id include-entities trim-user
                                include-my-retweet)))

(define (update/json cred status :key (in-reply-to-status-id #f)
                     (lat #f) (long #f) (place-id #f)
                     (display-coordinates #f)
                     (trim-user #f) (possibly-sensitive #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/statuses/update"
                    (api-params _keys status in-reply-to-status-id
                                lat long place-id
                                display-coordinates
                                trim-user possibly-sensitive)))

(define (update-with-media/json
         cred status media
         :key (possibly-sensitive #f)
         (in-reply-to-status-id #f)
         (lat #f) (long #f) (place-id #f)
         (display-coordinates #f)
         :allow-other-keys _keys)
  (call/oauth-post->json
   cred "/1.1/statuses/update_with_media"
   (map (^m `("media[]" :file ,m)) media)
   (api-params _keys status possibly-sensitive
                in-reply-to-status-id lat long
                place-id display-coordinates)))

(define (destroy/json cred id :key (trim-user #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/statuses/destroy/~|id|"
                    (api-params _keys trim-user)))

(define (retweet/json cred id :key (trim-user #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'post #"/1.1/statuses/retweet/~|id|"
                    (api-params _keys trim-user)))

(define (retweets/json cred id :key (count #f)
                       (trim-user #f)
                       :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/statuses/retweets/~|id|"
                    (api-params _keys count trim-user)))

;; required ID or URL not both.
(define (oembed/json cred id url
                     :key (maxwidth #f) (omit-script #f)
                     (hide-media #f) (hide-thread #f)
                     (align #f) (related #f) (lang #f)
                     (widget-type #f) (hide-tweet #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/statuses/oembed"
                    (api-params _keys id url
                                maxwidth hide-media hide-thread
                                omit-script align related lang
                                widget-type hide-tweet)))

;; 2020-06-05 Newly created api. publish.twitter.com endpoint
;; See https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-oembed
(define (oembed url . _keys)
  (call-publish-api
   "https://publish.twitter.com/oembed"
   'get '()
   (api-params _keys url)))

(define (retweeters/ids/json cred id :key (cursor #f) (stringify-ids #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/statuses/retweeters/ids"
                    (api-params _keys id cursor stringify-ids)))

(define (lookup/json cred id :key (include-entities #f)
                     (trim-user #f) (map #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'get #"/1.1/statuses/lookup"
                    (api-params _keys id include-entities trim-user map)))

;;;
;;; Utilities
;;;

;; Returns tweet id on success
(define (update cred message . opts)
  (assoc-ref
   (values-ref (apply update/json cred message opts) 0)
   "id"))
