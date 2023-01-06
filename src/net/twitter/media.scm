(define-module net.twitter.media
  (extend net.twitter.base)
  (export
   status/json upload/json)
   )
(select-module net.twitter.media)

;; # TODO
;; WARN: This module still not working
;; consider to use with `net.twitter.media+` module.

;; TODO FIXME Seems not working yet
(define (status/json cred media-id)
  (call/oauth->json
   cred 'uploading-status
   #"/1.1/media/upload"
   (api-params `(:command "STATUS") media-id)))

;; ##
;; - :media : <string> binary data
;; - :media-data : <string> base64 encoded data.
(define (upload/json cred :key (media #f) (media-data #f)
                     :allow-other-keys _keys)
  (let1 mime-part
      (cond
       [media
        `((media :value ,media))]
       [media-data
        `((media_data :value ,media-data :content-transfer-encoding "base64"))]
       [else
        #f])

    (call/oauth-upload->json
     cred #"/1.1/media/upload"
     mime-part (api-params _keys))))
