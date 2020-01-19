;;;
;;; Test net_twitter
;;;

(use gauche.test)

(test-start "net_twitter")
(use net.twitter)
(test-module 'net.twitter)

;; The following is a dummy test code.
;; Replace it for your tests.
;; (test* "test-net_twitter" "net_twitter is working"
;;        (test-net_twitter))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)




