(use gauche.test)

(define (main args)
  (test-start "Start test all module")
  (executable-test)
  (test-end :exit-on-failure #t))

(define (executable-test)
  (test-script "net/twitauth.scm")
  (test-script "net/twitter/app/upload-media.scm"))
