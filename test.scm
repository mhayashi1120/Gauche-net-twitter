;;;
;;; Test net.twitter
;;;

(use gauche.test)

(test-start "net.twitter")
(use net.twitter)
(test-module 'net.twitter)

(debug-print-width #f)

(use util.list)
(use file.util)
(use rfc.uri)
(use rfc.http)
(use srfi-1)

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
  (sys-sleep 2))

;; exercise

(test-and* "help test"
  (twitter-help-test/sxml *cred*))

(test-and* "help configuration"
  (twitter-help-configuration/sxml *cred*))

(test-and* "help languages"
  (twitter-help-languages/sxml *cred*))

(test-and* "legal tos"
  (twitter-legal-tos/sxml *cred*))

(test-and* "legal privacy"
  (twitter-legal-privacy/sxml *cred*))

(use srfi-19)
(use sxml.sxpath)

(test-and* "show user"
  (twitter-user-show/sxml *cred* :id (assoc-ref *settings* 'user)))

(let ((msg (string-append "マルチバイト文字と日付 " (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
      (user-id #f)
      (user-id2 #f)
      (status-id #f))

  (test-and* "update status"
    (set! status-id (twitter-update *cred* msg)))

  ;;TODO huh?
  (wait-a-while)

  (test* "show status"
         msg
         ((if-car-sxpath '(status text *text*)) (twitter-show/sxml *cred* status-id)))

  (test-and* "fetching user info"
    (set! user-id 
          (let1 sxml (twitter-user-show/sxml *cred* :id (assoc-ref *settings* 'user))
            ((if-car-sxpath '(user id *text*)) sxml)))
    (set! user-id2
          (let1 sxml (twitter-user-show/sxml *cred* :id (assoc-ref *settings* 'user2))
            ((if-car-sxpath '(user id *text*)) sxml))))

  (test-and* "fetching timeline by id"
    (twitter-user-timeline/sxml #f :id (assoc-ref *settings* 'user)))

  (test-and* "fetching timeline by user-id"
    (twitter-user-timeline/sxml #f :user-id user-id))

  (test-and* "fetching public timeline"
    (twitter-public-timeline/sxml))

  (test-and* "fetching home timeline"
    (twitter-home-timeline/sxml *cred*))

  (test-and* "fetching mentions"
    (twitter-mentions/sxml *cred*))

  (test-and* "searching"
    (twitter-search/sxml (assoc-ref *settings* 'user)))

  (test-and* "creating friendships"
    (twitter-friendship-create/sxml *cred* (assoc-ref *settings* 'user2))
    (twitter-friendship-create/sxml *cred2* (assoc-ref *settings* 'user)))

  (let ((msg (string-append "a direct message" (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
        (dm-id #f))

    (test-and* "sending direct message"
      (set! dm-id 
            ((if-car-sxpath '(// id *text*)) 
             (twitter-direct-message-new/sxml *cred* (assoc-ref *settings* 'user2) msg))))

    ;;TODO huh?
    (wait-a-while)

    (test* "sent direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (twitter-direct-messages-sent/sxml *cred*)))

    (test* "received direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (twitter-direct-messages/sxml *cred2*)))

    (test-and* "destroying direct message"
      (twitter-direct-message-destroy/sxml *cred* dm-id)))

  (test-and* "retweeting status"
    (twitter-retweet/sxml *cred2* status-id))

  (test-and* "retweets of status"
    (twitter-retweets/sxml *cred* status-id)
    (twitter-retweeted-by/sxml *cred* status-id)
    (twitter-retweeted-by-ids/sxml *cred* status-id))

  (test-and* "retweets of me"
    (twitter-retweets-of-me/sxml *cred*))

  (test-and* "retweeted by him"
    (twitter-retweeted-by-me/sxml *cred2*))

  (test-and* "favorite status"
    (twitter-favorite-create/sxml *cred2* status-id))

  (test-and* "favorites"
    (twitter-favorites/sxml *cred* user-id2))

  (test-and* "unfavorite status"
    (twitter-favorite-destroy/sxml *cred2* status-id))

  (test-and* "friend ids"
    (twitter-friends/ids/sxml *cred*))

  (test-and* "follower ids"
    (twitter-followers/ids/sxml *cred*))

  (let ((id #f))
    (test-and* "create saved search"
      (let1 sxml (twitter-saved-search-create/sxml *cred* "TEST exclude:retweets")
        (set! id ((if-car-sxpath '(// id *text*)) sxml))))

    (test-and* "showing saved search"
      (twitter-saved-search-show/sxml *cred* id))

    (test-and* "list saved searches"
      (twitter-saved-searches/sxml *cred*))

    (test-and* "destroying saved search"
      (twitter-saved-search-destroy/sxml *cred* id)))

  (test-and* "destroying friendships"
    (twitter-friendship-destroy/sxml *cred* (assoc-ref *settings* 'user2))
    (twitter-friendship-destroy/sxml *cred2* (assoc-ref *settings* 'user)))

  (test-and* "deleting status"
    (twitter-destroy/sxml *cred* status-id))

  (test-and* "block"
    (twitter-block-create/sxml *cred* :id (assoc-ref *settings* 'user2))
    (twitter-block-exists? *cred* :id (assoc-ref *settings* 'user2))
    (member user-id2 (twitter-blocks/ids *cred*))
    (twitter-block-destroy/sxml *cred* :id (assoc-ref *settings* 'user2)))

  )

;; TODO list api
;; TODO streaming api

(test-and* "rate limit user1"
  (twitter-account-rate-limit-status/sxml *cred*))

(test-and* "account credentials"
  (twitter-account-verify-credentials? *cred*))

(use srfi-13)
(use srfi-27)
(define (random-color)
  (string-pad (number->string (random-integer #x1000000) 16) 6 #\0))

(test-and* "update profile color"
  (twitter-account-update-profile-colors/sxml 
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
  (twitter-account-update-profile-image/sxml *cred* (random-mini-picture)))

(test-and* "update profile background image"
  (twitter-account-update-profile-background-image/sxml *cred* (random-big-picture) :tile #t))

(test-start "net.favotter")
(use net.favotter)
(test-module 'net.favotter)

(test-end)





