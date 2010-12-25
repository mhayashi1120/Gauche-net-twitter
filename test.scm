;;;
;;; Test net.twitter
;;;

(use gauche.test)

(test-start "net.twitter")
(use net.twitter)
(test-module 'net.twitter)

(test-start "net.favotter")
(use net.favotter)
(test-module 'net.favotter)

(test-end)





