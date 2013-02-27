(define-module net.twitter.status
  (use srfi-1)
  (use net.twitter.core)
  (export
   status-update
   status-show/json
   status-update/json
   status-update-with-media/json
   status-destroy/json
   status-retweet/json
   status-retweets/json
   ))
(select-module net.twitter.status)

;;;
;;; JSON api
;;;

;; cred can be #f to view public tweet.
(define (status-show/json cred id :key (include-entities #f) (trim-user #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/statuses/show"
					(api-params _keys id include-entities trim-user)))

(define (status-update/json cred message :key (in-reply-to-status-id #f)
                            (lat #f) (long #f) (place-id #f)
                            (display-coordinates #f)
                            (trim-user #f) (include-entities #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/statuses/update"
                    `(("status" ,message)
                      ,@(api-params _keys in-reply-to-status-id lat long
                                    place-id display-coordinates
                                    trim-user include-entities))))

(define (status-update-with-media/json
         cred message media
         :key (possibly-sensitive #f)
         (in-reply-to-status-id #f)
         (lat #f) (long #f) (place-id #f)
         (display-coordinates #f)
         :allow-other-keys _keys)
  (call/oauth-upload->json
   cred "/1.1/statuses/update_with_media"
   (map (^ (i m) `("media[]"
                   :file ,m
                   :content-type "image/jpeg"
                   ))
        (iota (length media) 0) media)
   `(("status" ,message)
     ,@(api-params _keys possibly-sensitive
                   in-reply-to-status-id lat long
                   place-id display-coordinates))))

(define (status-destroy/json cred id)
  (call/oauth->json cred 'post #`"/1.1/statuses/destroy/,|id|"
                    (api-params '())))

(define (status-retweet/json cred id)
  (call/oauth->json cred 'post #`"/1.1/statuses/retweet/,|id|"
                    (api-params '())))

(define (status-retweets/json cred id :key (count #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/statuses/retweets/,|id|"
                    (api-params _keys count)))

;;;
;;; Utilities
;;;

;; Returns tweet id on success
(define (status-update cred message . opts)
  ;;TODO to-string 
  (x->string (assoc-ref
              (values-ref (apply status-update/json cred message opts) 0)
              "id")))

