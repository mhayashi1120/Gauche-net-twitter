;; -*- mode: lisp -*-
;; 1. copy this "sample.test-settings.scm" to ".secret/test-settings.scm"
;; 2. create 2 twitter test account
;; 3. fill the following sexp.  `oauth-token` fields are generated by `twitauth`.
(
 (user . "***YOUR USERNAME***")
 (password . "***YOUR PASSWORD***")
 (consumer-key . "***YOUR CONSUMER KEY***")
 (consumer-secret-key . "***YOUR CONSUMER SECRET KEY***")

 ;; temporary settings
 (oauth-token . ((consumer-key        . "")
                 (consumer-secret     . "")
                 (access-token        . "")
                 (access-token-secret . "")))

 (user2 . "***YOUR SECOND USERNAME***")
 (password2 . "***YOUR SECOND PASSWORD***")

 (oauth-token2 . ((consumer-key        . "")
                  (consumer-secret     . "")
                  (access-token        . "")
                  (access-token-secret . "")))
 )
