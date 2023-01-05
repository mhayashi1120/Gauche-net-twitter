(define-module net.twitter.media+
  (extend net.twitter.media)
  (use rfc.http)
  (use file.util)
  (use gauche.uvector)
  (export
   upload-media
   ;; TODO Obsoleted
   upload))
(select-module net.twitter.media+)

;; Sample implementation Upload media. See:
;; https://developer.twitter.com/en/docs/media/upload-media/uploading-media/media-best-practices

(autoload rfc.base64 base64-encode-string)

(define-in-module rfc.http (media-multipart-sender params)
  (^[hdrs encoding header-sink]
    (receive (body boundary) (http-compose-form-data params #f encoding)
      (let* ([size (string-size body)]
             [hdrs `(("content-length" ,(x->string size))
                     ("mime-version" "1.0")
                     ("content-type" ,#"multipart/form-data; boundary=\"~|boundary|\"")
                     ,@(alist-delete "content-type" hdrs equal?))]
             [body-sink (header-sink hdrs)]
             [port (body-sink size)])
        ;; maybe stuck with port buffer size
        (call-with-input-string body (cut copy-port <> port :size size))
        (body-sink 0)))))

(define-macro (hack-multipart-sender . expr)
  (let ([original (gensym)])
    `(let ([,original #f])
       (with-module rfc.http
         (set! ,original http-multipart-sender)
         (set! http-multipart-sender media-multipart-sender))
       (unwind-protect
        (begin ,@expr)
        (with-module rfc.http
          (set! http-multipart-sender ,original))))))

;; ##
;; - :callback-progress : <procedure> accept 3 arguments.
;;   SEQUENCE:<integer> -> SIZE:<integer> -> {<json> | #f} -> <void>
(define (upload-media
         cred file media-type
         :key
         (callback-progress (^ _))
         (chunk-size (ash 1 20)))
  (let* ([size (file-size file)]
         ;; https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-init
         [init/json
          (upload/json
           cred
           :command "INIT"
           :media-type media-type
           :total-bytes size)]
         [media-id (assoc-ref init/json "media_id")]
         [iport (open-input-file file)])


    (unwind-protect
     (let loop ([done 0]
                [segment 0]
                [progress/json init/json])

       (callback-progress segment done progress/json)

       (cond
        [(< done size)
         (let* ([bytes (read-uvector <u8vector> chunk-size iport)]
                [chunk (u8vector->string bytes)]
                [append/json
                 ;; append/json is no contents.
                 ;; https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-append
                 (hack-multipart-sender
                  (upload/json
                   cred
                   :media chunk
                   :media-id media-id
                   :command "APPEND"
                   :segment-index segment))]
                [done* (+ done (u8vector-length bytes))]
                [segment* (+ segment 1)])

           (callback-progress segment* done* #f)

           (loop done*
                 segment*
                 append/json))]
        [else
         (let1 finalize/json
             (upload/json
              cred
              :command "FINALIZE"
              :media-id media-id)
           ;; https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-finalize
           (callback-progress (+ segment 1) done finalize/json))]))
     (close-port iport))

    media-id))

;; ## TODO This procedure obsoleted
;; - :callback-progress : Procedure that accept 3 args <json> or #f, uploaded-size, segment
(define (upload cred file media-type
         :key
         (callback-progress (^ x))
         (chunk-size (ash 1 20)))

  (upload-media
   cred file media-type
   ;; Backward compat
   :callback-progress (^ [sequence size maybe-json]
                        (when maybe-json
                          (callback-progress maybe-json size sequence)))
   :chunk-size chunk-size))

