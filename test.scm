;;;
;;; Test net_twitter
;;;

(use gauche.process)
(use gauche.test)

(test-start "net.twitter")

(use net.twitter)
(test-module 'net.twitter)

(test* "Sub module"
       #t
       (do-process `(gosh "./__tests__/module.scm")))

(test* "Snowflake module"
       #t
       (do-process `(gosh "./__tests__/snowflake.scm")))

(test-end :exit-on-failure #t)
