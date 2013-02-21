(define-module net.twitter.tweet
  (use srfi-1)
  (use net.twitter.core)
  (use sxml.sxpath)
  (export
   show/sxml
   update/sxml
   update
   update-with-media/sxml
   destroy/sxml
   retweet/sxml
   retweets/sxml
   retweeted-by/sxml
   retweeted-by-ids/sxml

   show/json
   update/json
   update-with-media/json
   destroy/json
   retweet/json
   retweets/json
   retweeted-by/json
   retweeted-by-ids/json
   ))
(select-module net.twitter.tweet)

;;;
;;; XML api
;;;

;; cred can be #f to view public tweet.
(define (show/sxml cred id :key (include-entities #f) (trim-user #f)
                   :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/show/,|id|"
					(api-params _keys include-entities trim-user)))

(define (update/sxml cred message :key (in-reply-to-status-id #f)
                     (lat #f) (long #f) (place-id #f)
                     (display-coordinates #f)
                     (trim-user #f) (include-entities #f)
                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/statuses/update"
                    `(("status" ,message)
                      ,@(api-params _keys in-reply-to-status-id lat long
                                    place-id display-coordinates
                                    trim-user include-entities))))

;; Returns tweet id on success
(define (update cred message . opts)
  ((if-car-sxpath '(// status id *text*))
   (values-ref (apply update/sxml cred message opts) 0)))

(define (update-with-media/sxml cred message media
                                :key (possibly-sensitive #f)
                                (in-reply-to-status-id #f)
                                (lat #f) (long #f) (place-id #f)
                                (display-coordinates #f)
                                :allow-other-keys _keys)
  (call/oauth-upload->sxml
   cred "/1/statuses/update_with_media"
   (map (^ (i m) `("media[]"
                   :file ,m
                   :content-type "image/jpeg"
                   ))
        (iota (length media) 0) media)
   `(("status" ,message)
     ,@(api-params _keys possibly-sensitive
                   in-reply-to-status-id lat long
                   place-id display-coordinates))))

(define (destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/destroy/,|id|"
                    (api-params '())))

(define (retweet/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/retweet/,|id|"
                    (api-params '())))

(define (retweets/sxml cred id :key (count #f)
                       :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets/,|id|"
                    (api-params _keys count)))

(define (retweeted-by/sxml cred id :key (count #f) (page #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by"
                    (api-params _keys count page)))

(define (retweeted-by-ids/sxml cred id :key (count #f) (page #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by/ids"
                    (api-params _keys count page)))

;;;
;;; JSON api
;;;

;; cred can be #f to view public tweet.
(define (show/json cred id :key (include-entities #f) (trim-user #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/statuses/show/,|id|"
					(api-params _keys include-entities trim-user)))

(define (update/json cred message :key (in-reply-to-status-id #f)
                     (lat #f) (long #f) (place-id #f)
                     (display-coordinates #f)
                     (trim-user #f) (include-entities #f)
                     :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/statuses/update"
                    `(("status" ,message)
                      ,@(api-params _keys in-reply-to-status-id lat long
                                    place-id display-coordinates
                                    trim-user include-entities))))

(define (update-with-media/json cred message media
                                :key (possibly-sensitive #f)
                                (in-reply-to-status-id #f)
                                (lat #f) (long #f) (place-id #f)
                                (display-coordinates #f)
                                :allow-other-keys _keys)
  (call/oauth-upload->json
   cred "/1/statuses/update_with_media"
   (map (^ (i m) `("media[]"
                   :file ,m
                   :content-type "image/jpeg"
                   ))
        (iota (length media) 0) media)
   `(("status" ,message)
     ,@(api-params _keys possibly-sensitive
                   in-reply-to-status-id lat long
                   place-id display-coordinates))))

(define (destroy/json cred id)
  (call/oauth->json cred 'post #`"/1/statuses/destroy/,|id|"
                    (api-params '())))

(define (retweet/json cred id)
  (call/oauth->json cred 'post #`"/1/statuses/retweet/,|id|"
                    (api-params '())))

(define (retweets/json cred id :key (count #f)
                       :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/statuses/retweets/,|id|"
                    (api-params _keys count)))

(define (retweeted-by/json cred id :key (count #f) (page #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/statuses/,|id|/retweeted_by"
                    (api-params _keys count page)))

(define (retweeted-by-ids/json cred id :key (count #f) (page #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/statuses/,|id|/retweeted_by/ids"
                    (api-params _keys count page)))
