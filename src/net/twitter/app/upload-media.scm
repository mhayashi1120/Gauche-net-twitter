(use util.match)
(use gauche.parseopt)
(use rfc.json)
(use net.twitter.media+)
(use net.twitter.auth.persistent)

(define (usage)
  (print "Usage: gosh net/twitter/app/upload-media.scm [OPTIONS] CREDENTIAL-FILE UPLOAD-FILE [...]")
  (print "   Upload media api via Twitter v1 interface")
  (print "   OPTIONS : [-j | --json | --print-json] | [-t | --text | --print-text] \\")
  (print "             [-s | --silent]")
  (print "   Currently this command just check UPLOAD-FILE extension as media-type detection.")
  (print "   Supported types and extensions are:")
  (print "      - image/jpeg : as \"jpeg\" or \"jpg\" extension.")
  (print "      - image/png : as \"png\" extension.")
  (print "   --silent : Do not show progress message.")
  ;; TODO describe about json field.
  (print "   --print-json : Print upload result as json.")
  (print "   --print-text : Print upload result as text. Default behavior.")
  (exit 0))

(define (%popup fmt . args)
  (apply format #t fmt args)
  (flush))

(define (%progress index size maybe-json)
  (cond
   [silent?]
   [(= index 0)
    (%popup "Starting upload")]
   [(not maybe-json)
    (%popup ".")]
   [else
    (%popup " done. (~a bytes)\n"
            size)]))

(define (%detect-type file)
  (cond
   [(#/\.jpe?g$/ file)
    "image/jpeg"]
   [(#/\.png$/ file)
    "image/png"]
   [else
    (error "Not a supported extension file." file)]))

;; ##
;; -> ((ARGUMENT:<string> MEDIA-ID:<string>) ...)
(define (%do-upload! cred files)
  (map
   (^ [file]
     (let* ([media-type (%detect-type file)]
            [media-id (upload-media cred file media-type :callback-progress %progress)])
       (when (eq? print-mode 'text)
         (%popup "~s upload as ~a\n" file media-id))
       (list file media-id)))
   files))

(autoload rfc.json construct-json)

;; ##
;; -> <void>
(define (%print-result result)
  (ecase print-mode
    [(text)
     ;; Do nothing here
     #f]
    [(json)
     (construct-json
      (cond-list
       [#t (cons 'data (list->vector
                        (map
                         (match-lambda
                          [(argument media-id)
                           (list
                            (cons 'input argument)
                            (cons 'mediaId media-id))])
                         result)))]))]))

(define print-mode 'text)
(define silent? #f)

;;;
;;; Entry
;;;

(define (main args)
  (let-args (cdr args)
      ([_ "j|json|print-json"
          => (^[] (set! print-mode 'json))]
       [_ "t|text|print-text"
          => (^[] (set! print-mode 'text))]
       [_ "s|silent"
          => (^[] (set! silent? #f))]
       . restargs)
    (match restargs
      [(credential-file . (? pair? files))
       (let* ([cred (read-credential credential-file)]
              [result (%do-upload! cred files)])
         (%print-result result))]
      [else
       (usage)]))
  0)
