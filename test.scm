;;;
;;; Test net.twitter
;;;

(use gauche.test)

(add-load-path ".")

(use gauche.process)
(use file.util)
(use net.favotter)
(use net.twitter)
(use net.twitter.account)
(use net.twitter.auth)
(use net.twitter.block)
(use net.twitter.core)
(use net.twitter.direct-message)
(use net.twitter.favorite)
(use net.twitter.friendship)
(use net.twitter.help)
(use net.twitter.legal)
(use net.twitter.list)
(use net.twitter.saved-search)
(use net.twitter.search)
(use net.twitter.spam)
(use net.twitter.timeline)
(use net.twitter.tweet :prefix tweet:)
(use net.twitter.user)
(use rfc.http)
(use rfc.uri)
(use srfi-1)
(use srfi-13)
(use srfi-19)
(use srfi-27)
(use sxml.sxpath)
(use util.list)

(define *settings*
  (with-input-from-file ".test-settings.scm"
    read))

(define *cred*
  (begin
    ;; (twitter-authenticate-client
    ;;  (assoc-ref *settings* 'consumer-key)
    ;;  (assoc-ref *settings* 'consumer-secret-key)
    ;;  (lambda (url)
    ;;    (receive (scheme user-info host port path query fragment)
    ;;        (uri-parse url)
    ;;      (receive (code headers body)
    ;;          (http-get host #`",|path|?,|query|"
    ;;                    :secure #t
    ;;                    ;;TODO not supported yet
    ;;                    :auth-user (assoc-ref *settings* 'user)
    ;;                    :auth-password (assoc-ref *settings* 'password))
    ;;        (if-let1 m (#/<code>([0-9]+)<\/code>/ body)
    ;;          (m 1)
    ;;          #f)))))

    ;; Delete after rfc.http auth-user implemented
    (define (from-token key)
      (assq-ref (assq-ref *settings* 'oauth-token) key))

    (make <twitter-cred>
      :consumer-key         (from-token 'consumer-key)
      :consumer-secret      (from-token 'consumer-secret)
      :access-token         (from-token 'access-token)
      :access-token-secret  (from-token 'access-token-secret))))

(define *cred2*
  (begin

    ;; Delete after rfc.http auth-user implemented
    (define (from-token key)
      (assq-ref (assq-ref *settings* 'oauth-token2) key))

    (make <twitter-cred>
      :consumer-key         (from-token 'consumer-key)
      :consumer-secret      (from-token 'consumer-secret)
      :access-token         (from-token 'access-token)
      :access-token-secret  (from-token 'access-token-secret))))

;; check only non error have occur.
(define-macro (test-and* name . expr)
  `(test* ,name 
          #t 
          (and ,@expr #t)))

(define (wait-a-while)
  (sys-sleep 10))

(map
 test-module
 '(
   net.twitter.user
   net.twitter.tweet
   net.twitter.trends
   net.twitter.timeline
   net.twitter.stream
   net.twitter.spam
   net.twitter.search
   net.twitter.saved-search
   net.twitter.notification
   net.twitter.list
   net.twitter.legal
   net.twitter.help
   net.twitter.friendship
   net.twitter.favorite
   net.twitter.direct-message
   net.twitter.core
   net.twitter.block
   net.twitter.auth
   net.twitter.account
   net.favotter
   net.twitter
   ))

(define (test-executable file)
  ;;FIXME only output the result...
  (run-process 
   `(gosh -b -l ,file -u "gauche.test" -e "(begin (test-module 'user) (exit 0))")
   :wait #t))

(test-executable "net/twitauth.scm")

;; exercise


(test-and* "help test"
  (help-test/sxml *cred*))

(test-and* "help configuration"
  (help-configuration/sxml *cred*))

(test-and* "help languages"
  (help-languages/sxml *cred*))

(test-and* "legal tos"
  (legal-tos/sxml *cred*))

(test-and* "legal privacy"
  (legal-privacy/sxml *cred*))

(test-and* "show user"
  (user-show/sxml *cred* :id (assoc-ref *settings* 'user)))

(let ((msg (string-append "マルチバイト文字と日付 " (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
      (user-id #f)
      (user-id2 #f)
      (status-id #f))

  (test-and* "update status"
    (set! status-id (tweet:update *cred* msg)))

  ;;TODO why?
  (wait-a-while)

  (test* "show status"
         msg
         ((if-car-sxpath '(status text *text*)) (tweet:show/sxml *cred* status-id)))

  (test-and* "fetching user info"
    (set! user-id 
          (let1 sxml (user-show/sxml *cred* :id (assoc-ref *settings* 'user))
            ((if-car-sxpath '(user id *text*)) sxml)))
    (set! user-id2
          (let1 sxml (user-show/sxml *cred* :id (assoc-ref *settings* 'user2))
            ((if-car-sxpath '(user id *text*)) sxml))))

  (test-and* "fetching timeline by id"
    (user-timeline/sxml #f :id (assoc-ref *settings* 'user)))

  (test-and* "fetching timeline by user-id"
    (user-timeline/sxml #f :user-id user-id))

  (test-and* "fetching public timeline"
    (public-timeline/sxml))

  (test-and* "fetching home timeline"
    (home-timeline/sxml *cred*))

  (test-and* "fetching mentions"
    (mentions/sxml *cred*))

  (test-and* "searching"
    (search/sxml (assoc-ref *settings* 'user)))

  (test-and* "creating friendships"
    (friendship-create/sxml *cred* (assoc-ref *settings* 'user2))
    (friendship-create/sxml *cred2* (assoc-ref *settings* 'user)))

  (let ((msg (string-append "a direct message" (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
        (dm-id #f))

    (test-and* "sending direct message"
      (set! dm-id 
            ((if-car-sxpath '(// id *text*)) 
             (direct-message-new/sxml *cred* (assoc-ref *settings* 'user2) msg))))

    ;;TODO huh?
    (wait-a-while)

    (test* "sent direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (direct-messages-sent/sxml *cred*)))

    (test* "received direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (direct-messages/sxml *cred2*)))

    (test-and* "destroying direct message"
      (direct-message-destroy/sxml *cred* dm-id)))

  (test-and* "retweeting status"
    (tweet:retweet/sxml *cred2* status-id))

  (test-and* "retweets of status"
    (tweet:retweets/sxml *cred* status-id)
    (tweet:retweeted-by/sxml *cred* status-id)
    (tweet:retweeted-by-ids/sxml *cred* status-id))

  (test-and* "retweets of me"
    (retweets-of-me/sxml *cred*))

  (test-and* "retweeted by him"
    (retweeted-by-me/sxml *cred2*))

  (test-and* "favorite status"
    (favorite-create/sxml *cred2* status-id))

  (test-and* "favorites"
    (favorites/sxml *cred* user-id2))

  (test-and* "unfavorite status"
    (favorite-destroy/sxml *cred2* status-id))

  (test-and* "friend ids"
    (friends/ids/sxml *cred*))

  (test-and* "follower ids"
    (followers/ids/sxml *cred*))

  (let ((id #f))
    (test-and* "create saved search"
      (let1 sxml (saved-search-create/sxml *cred* "TEST exclude:retweets")
        (set! id ((if-car-sxpath '(// id *text*)) sxml))))

    (test-and* "showing saved search"
      (saved-search-show/sxml *cred* id))

    (test-and* "list saved searches"
      (saved-searches/sxml *cred*))

    (test-and* "destroying saved search"
      (saved-search-destroy/sxml *cred* id)))

  (test-and* "destroying friendships"
    (friendship-destroy/sxml *cred* (assoc-ref *settings* 'user2))
    (friendship-destroy/sxml *cred2* (assoc-ref *settings* 'user)))

  (test-and* "deleting status"
    (tweet:destroy/sxml *cred* status-id))

  (test-and* "block"
    (block-create/sxml *cred* :id (assoc-ref *settings* 'user2))
    (block-exists? *cred* :id (assoc-ref *settings* 'user2))
    (member user-id2 (blocks/ids *cred*))
    (block-destroy/sxml *cred* :id (assoc-ref *settings* 'user2)))
  )


;; TODO list api
;; TODO streaming api

(test-and* "rate limit user1"
  (account-rate-limit-status/sxml *cred*))

(test-and* "account credentials"
  (account-verify-credentials? *cred*))

(define (random-color)
  (string-pad (number->string (random-integer #x1000000) 16) 6 #\0))

(test-and* "update profile color"
  (account-update-profile-colors/sxml 
   *cred*
   :profile-background-color (random-color)
   :profile-text-color (random-color)
   :profile-link-color (random-color)
   :profile-sidebar-fill-color (random-color)
   :profile-sidebar-border-color (random-color)))

(define (random-picture lis)
  (build-path "./testdata" (list-ref lis (random-integer (length lis)))))

(define (random-mini-picture)
  (random-picture (filter (^x (#/-mini\.png$/ x)) (sys-readdir "./testdata"))))

(define (random-big-picture)
  (random-picture (filter (^x (#/^[^-]+\.png$/ x)) (sys-readdir "./testdata"))))

(test-and* "update profile image"
  (account-update-profile-image/sxml *cred* (random-mini-picture)))

(test-and* "update profile background image"
  (account-update-profile-background-image/sxml *cred* (random-big-picture) :tile #t))

(test-end)



