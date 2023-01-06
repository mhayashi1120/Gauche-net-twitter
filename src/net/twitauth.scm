;;;
;;;  This is a convenience script to obtain access token.
;;;

(use net.twitter.auth)
(use net.twitter.auth.persistent)
(use util.match)
(use gauche.parseopt)

(define (usage)
  (print "Usage: gosh net/twitauth [{-o | --output-file} FILE] [consumer-key consumer-secret]")
  (print "  Without arguments, it prompts to enter the application's")
  (print "  consumer-key and consumer-secret.")
  (print "  After it obtains a request token, it asks the user to")
  (print "  visit a twitter url and get a PIN shown there, and promts")
  (print "  the user to enter the PIN.  Then it prints access-token")
  (print "  and access-token-secret, with consumer-key and consumer-secret,")
  (print "  to the stdout.  Copy them to your application settings to")
  (print "  to access Twitter by the application on behalf of the user.")
  (print "  -o | --output-file : Save credential to the FILE.")
  (exit 0))

(define (main args)
  (let-args (cdr args)
      ([output-file "o|output-file=s"]
       [_ "h|help" => (^[] (usage))]
       . restargs)

    (match restargs
      [()
       (display "Enter consumer key: ") (flush)
       (let1 key (read-line)
         (when (eof-object? key) (exit 1 "aborted."))
         (display "Enter consumer secret: ") (flush)
         (let1 secret (read-line)
           (when (eof-object? secret) (exit 1 "aborted."))
           (report (twitter-authenticate-client key secret) output-file)))]
      [(key secret)
       (report (twitter-authenticate-client key secret) output-file)]
      [_ (usage)]))
  0)

(define (report cred :optional (file #f))
  (cond
   [file
    (call-with-output-file file
      (^p (print-credential cred p)))
    (format #t "Save credential to ~s\n" file)]
   [else
    (print-credential cred)]))
