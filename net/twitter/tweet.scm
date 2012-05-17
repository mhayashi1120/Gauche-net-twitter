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
   ))
(select-module net.twitter.tweet)

;; cred can be #f to view public tweet.
(define (show/sxml cred id :key (include-entities #f) (trim-user #f)
                   :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/show/,|id|.xml"
					(api-params _keys include-entities trim-user)))

(define (update/sxml cred message :key (in-reply-to-status-id #f)
                     (lat #f) (long #f) (place-id #f)
                     (display-coordinates #f)
                     (trim-user #f) (include-entities #f)
                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/statuses/update.xml"
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
   cred "/1/statuses/update_with_media.xml"
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
  (call/oauth->sxml cred 'post #`"/1/statuses/destroy/,|id|.xml"
                    (api-params '())))

(define (retweet/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/retweet/,|id|.xml"
                    (api-params '())))

(define (retweets/sxml cred id :key (count #f)
                       :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets/,|id|.xml"
                    (api-params _keys count)))

(define (retweeted-by/sxml cred id :key (count #f) (page #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by.xml"
                    (api-params _keys count page)))

(define (retweeted-by-ids/sxml cred id :key (count #f) (page #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by/ids.xml"
                    (api-params _keys count page)))

