(define-module net.twitter.tweet
  (use sxml.sxpath)
  (use srfi-1)
  (use net.twitter.core)
  (use util.list)
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
(define (show/sxml cred id :key (include-entities #f) (trim-user #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/show/,|id|.xml"
					(make-query-params include-entities trim-user)))

(define (update/sxml cred message :key (in-reply-to-status-id #f)
                             (lat #f) (long #f) (place-id #f)
                             (display-coordinates #f)
                             (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'post "/1/statuses/update.xml"
                    `(("status" ,message)
                      ,@(make-query-params in-reply-to-status-id lat long
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
                                        (display-coordinates #f))
  (call/oauth-upload->sxml
   cred "/1/statuses/update_with_media.xml"
   (map (^ (i m) `("media[]"
                   :file ,m
                   :content-type "image/jpeg"
                   ))
        (iota (length media) 0) media)
   `(("status" ,message)
     ,@(make-query-params possibly-sensitive
                          in-reply-to-status-id lat long
                          place-id display-coordinates))))

(define (destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/destroy/,|id|.xml" '()))

(define (retweet/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/retweet/,|id|.xml" '()))

(define (retweets/sxml cred id :key (count #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets/,|id|.xml"
                    (make-query-params count)))

(define (retweeted-by/sxml cred id :key (count #f) (page #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by.xml"
                    (make-query-params count page)))

(define (retweeted-by-ids/sxml cred id :key (count #f) (page #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by/ids.xml"
                    (make-query-params count page)))

