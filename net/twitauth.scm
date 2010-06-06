;;;
;;;  This is a convenience script to obtain access token.
;;;  

(use net.twitter)
(use util.match)

(define (usage)
  (print "Usage: gosh net/twitauth [consumer-key consumer-secret]")
  (print "  Without arguments, it prompts to enter the application's")
  (print "  consumer-key and consumer-secret.")
  (print "  After it obtains a request token, it asks the user to")
  (print "  visit a twitter url and get a PIN shown there, and promts")
  (print "  the user to enter the PIN.  Then it prints access-token")
  (print "  and access-token-secret, with consumer-key and consumer-secret,")
  (print "  to the stdout.  Copy them to your application settings to")
  (print "  to access Twitter by the application on behalf of the user.")
  (exit 0))

(define (main args)
  (match (cdr args)
    [()
     (display "Enter consumer key: ") (flush)
     (let1 key (read-line)
       (when (eof-object? key) (exit 1 "aborted."))
       (display "Enter consumer secret: ") (flush)
       (let1 secret (read-line)
         (when (eof-object? secret) (exit 1 "aborted."))
         (report (twitter-authenticate-client key secret))))]
    [(key secret) (report (twitter-authenticate-client key secret))]
    [_ (usage)])
  0)

(define (report cred)
  (print "(")
  (print " (consumer-key        . \""(ref cred'consumer-key)"\")")
  (print " (consumer-secret     . \""(ref cred'consumer-secret)"\")")
  (print " (access-token        . \""(ref cred'access-token)"\")")
  (print " (access-token-secret . \""(ref cred'access-token-secret)"\")")
  (print ")"))
         
