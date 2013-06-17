(use gauche.test)

(use net.twitter.snowflake)

(define (main args)
  (test-start "Start snowflake")
  (module-test)
  (test-end))

(define (module-test)
  (test-module 'net.twitter.snowflake)
  (test* "With no error"
         #t
         (begin (snowflake-time #x400000) #t))

  (test* "With no error"
         #t
         (begin (snowflake-time #xffffffffffffffff) #t))

  (test* "Not enough bit"
         (test-error <error>)
         (snowflake-time #x3fffff))

  (test* "Overflow"
         (test-error <error>)
         (snowflake-time #x10000000000000000))
  )
