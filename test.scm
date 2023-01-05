;;;
;;; Test net_twitter
;;;

(use gauche.process)
(use gauche.test)

(debug-print-width #f)

(test-start "net.twitter")

(use net.twitter)
(test-module 'net.twitter)

(define (%do script)
  (do-process `(gosh ,@(map (^l (format "-I~a" l)) *load-path*) ,script)))

(test* "Sub module"
       #t
       (%do "./__tests__/module.scm"))

(test* "Snowflake module"
       #t
       (%do "./__tests__/snowflake.scm"))

(test-end :exit-on-failure #t)
