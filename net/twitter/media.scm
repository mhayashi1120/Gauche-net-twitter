(define-module net.twitter.media
  (extend net.twitter.base)
  (export
   upload/json)
   )
(select-module net.twitter.media)

(define (upload/json cred :key (media #f) (media-data #f)
                     :allow-other-keys _keys)
  (let1 body (cond
              [media
               `((media ,media))]
              [media-data
               `((media_data ,media-data))]
              [else
               #f])
    (call/oauth-upload->json
     cred #`"/1.1/media/upload"
     body
     (api-params _keys))))
