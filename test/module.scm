(test-start "Start module")

(test-module 'net.twitter.user)
(test-module 'net.twitter.tweet)
(test-module 'net.twitter.trends)
(test-module 'net.twitter.timeline)
(test-module 'net.twitter.stream)
(test-module 'net.twitter.spam)
(test-module 'net.twitter.search)
(test-module 'net.twitter.saved-search)
(test-module 'net.twitter.notification)
(test-module 'net.twitter.list)
(test-module 'net.twitter.legal)
(test-module 'net.twitter.help)
(test-module 'net.twitter.friendship)
(test-module 'net.twitter.favorite)
(test-module 'net.twitter.direct-message)
(test-module 'net.twitter.core)
(test-module 'net.twitter.block)
(test-module 'net.twitter.auth)
(test-module 'net.twitter.account)
(test-module 'net.twitter.geo)
(test-module 'net.favotter)
(test-module 'net.twitter)

(define (test-executable file)
  ;;FIXME only output the result...
  (unwind-protect
   (run-process
    `(gosh -b
           -l ,file
           -u "gauche.test"
           -e "(begin (test-module 'user) (exit 0))")
    :wait #t)))

(test-executable "net/twitauth.scm")

(test-end)

