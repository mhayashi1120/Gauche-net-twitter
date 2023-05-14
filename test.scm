;;;
;;; Test net_twitter
;;;

(use gauche.process)
(use gauche.test)

(debug-print-width #f)

(test-start "net.twitter")

(dolist (pattern '(net.twitter net.twitter.* net.twitter.auth.* net.twitter.cursor.*))
  (library-for-each
   pattern
   ;; gauche `load` need ./ or ../ prefix.
   (^ [module path]
     (let1 path* #"./~|path|"
       (when (file-exists? path*)
         (load path*)
         (test-module module))))))

(define (%do script)
  (do-process `(gosh ,@(map (^l (format "-I~a" l)) *load-path*) ,script)))

(test* "Sub module"
       #t
       (%do "./__tests__/module.scm"))

(test* "Snowflake module"
       #t
       (%do "./__tests__/snowflake.scm"))

(test-end :exit-on-failure #t)
