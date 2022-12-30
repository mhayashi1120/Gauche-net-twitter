
(use gauche.test)

(use gauche.process)
(use file.util)
(use net.favotter)
(use net.twitter)
(use net.twitter.account :prefix account-)
(use net.twitter.auth)
(use net.twitter.block :prefix block-)
(use net.twitter.core)
(use net.twitter.dm :prefix dm:)
(use net.twitter.friendship :prefix friendship-)
(use net.twitter.geo)
(use net.twitter.help :prefix help-)
(use net.twitter.list :prefix ll-) ;; avoid dup of list procedure using `ll-`
(use net.twitter.saved-search :prefix ss:)
(use net.twitter.search :prefix search:)
(use net.twitter.timeline :prefix tl:)
(use net.twitter.status :prefix status-)
(use net.twitter.user :prefix user-)
(use net.twitter.favorite :prefix fav:)
(use rfc.http)
(use rfc.uri)
(use srfi-1)
(use srfi-13)
(use srfi-19)
(use srfi-27)
(use util.list)

(test-start "net.twitter")

(define *settings*
  (with-input-from-file ".secret/test-settings.scm"
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
    ;;          (http-get host #"~|path|?~|query|"
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
(define-macro (test!! name . expr)
  `(test* ,name
          #t
          (and ,@expr #t)))

(define (test-executable file)
  ;;FIXME only output the result...
  (unwind-protect
   (run-process
    `(gosh -b
           -l ,file
           -u "gauche.test"
           -e "(begin (test-module 'user) (exit 0))")
    :wait #t)))

(define (wait-a-while)
  (sys-sleep 10))

(test-script "net/twitauth.scm")

;; exercise


(test!! "help configuration"
  (help-configuration/json *cred*))

(test!! "help languages"
  (help-languages/json *cred*))

(test!! "show user"
  (user-show/json *cred* :id (assoc-ref *settings* 'user)))

(let ((msg (string-append "マルチバイト文字と日付 " (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
      (user-id #f)
      (user-id2 #f)
      (status-id #f))

  (test!! "update status"
    (set! status-id (status-update *cred* msg)))

  ;;TODO why?
  (wait-a-while)

  (test* "show status"
         msg
         (let1 json (status-show/json *cred* status-id)
           (assoc-ref json "text")))

  (test!! "fetching user info"
    (let1 json (user-show/json *cred* :id (assoc-ref *settings* 'user))
      (set! user-id (assoc-ref json "id"))
      user-id)

    (let1 json (user-show/json *cred* :id (assoc-ref *settings* 'user2))
      (set! user-id2 (assoc-ref json "id"))
      user-id2))

  (test!! "fetching timeline by id"
    (tl:user-timeline/json #f :id (assoc-ref *settings* 'user)))

  (test!! "fetching timeline by user-id"
    (tl:user-timeline/json #f :user-id user-id))

  (test!! "fetching home timeline"
    (tl:home-timeline/json *cred*))

  (test!! "fetching mentions"
    (tl:mentions-timeline/json *cred*))

  (test!! "searching"
    (search:search-tweets/json *cred* (assoc-ref *settings* 'user)))

  (test!! "creating friendships"
    (friendship-create/json *cred* (assoc-ref *settings* 'user2))
    (friendship-create/json *cred2* (assoc-ref *settings* 'user)))

  (let ((msg (string-append "a direct message" (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
        (dm-id #f))

    (test!! "sending direct message"
      (set! dm-id
            (let1 json (dm:send/json *cred* (assoc-ref *settings* 'user2) msg)
              (assoc-ref json "id"))))

    ;;TODO why?
    (wait-a-while)

    (test* "sent direct message"
           msg
           (let1 json (dm:sent/json *cred*)
             ;; TODO
             json))

    (test* "received direct message"
           msg
           ;; TODO
           (dm:list/json *cred2*))

    (test!! "destroying direct message"
      ;; TOO
      (dm:destroy/json *cred* dm-id)))

  (test!! "retweeting status"
    (status-retweet/json *cred2* status-id))

  (test!! "retweets of status"
    (status-retweets/json *cred* status-id)
    (status-retweeted-by/json *cred* status-id)
    (status-retweeted-by-ids/json *cred* status-id))

  (test!! "retweets of me"
    (tl:retweets-of-me/json *cred*))

  (test!! "retweeted by him"
    (tl:retweeted-by-me/json *cred2*))

  (test!! "favorite status"
    (fav:create/json *cred2* status-id))

  (test!! "favorites"
    (fav:list/json *cred* user-id2))

  (test!! "unfavorite status"
    (fav:destroy/json *cred2* status-id))

  (test!! "friend ids"
    (friendship-friends/ids *cred*))

  (test!! "follower ids"
    (friendship-followers/ids *cred*))

  (let ((id #f))
    (test!! "create saved search"
      ;; use date to avoid creation fail (cause of previous test error)
      (let* ([text (format "\"~a\" exclude:retweets" (date->string (current-date)))]
             [json (ss:create/json *cred* text)])
        (set! id (assoc-ref json "id"))))

    (test!! "showing saved search"
      (ss:show/json *cred* id))

    (test!! "list saved searches"
      (ss:show/json *cred*))

    (test!! "destroying saved search"
      (ss:destroy/json *cred* id)))

  (test!! "destroying friendships"
    (friendship-destroy/json *cred* (assoc-ref *settings* 'user2))
    (friendship-destroy/json *cred2* (assoc-ref *settings* 'user)))

  (test!! "deleting status"
    (status-destroy/json *cred* status-id))

  (test!! "block"
    (block-create/json *cred* :id (assoc-ref *settings* 'user2))
    (block-exists? *cred* :id (assoc-ref *settings* 'user2))
    (member user-id2 (blocks/ids *cred*))
    (block-destroy/json *cred* :id (assoc-ref *settings* 'user2)))
  )

(let* ([json (ll-create/json *cred* "hoge")]
       [id (assoc-ref json "id")])

  (test!! "a set of list api methods"
    (ll-show/json *cred* :list-id id)
    (ll-statuses/json *cred* :list-id id)
    (ll-update/json *cred* :list-id id :name "FOO")
    ;; check successfully created
    (equal? (assoc-ref (ll-show/json *cred* :list-id id) "id") "FOO")
    (ll-member-create/json *cred* :list-id id
                           :screen-name (assoc-ref *settings* 'user2))
    ;; list member was successfully created"
    (ll-member-show/json *cred* :list-id id
                         :screen-name (assoc-ref *settings* 'user2))

    ;; subscribe a created list.
    (ll-subscriber-create/json *cred2* :list-id id)

    ;; check the existence of subscriber was created.
    (ll-subscribers/json *cred* :list-id id)

    (member id (ll-memberships/ids *cred2* :list-id id))
    (member id (ll-subscriptions/ids *cred2* :list-id id))

    (ll-subscriber-destroy/json *cred2* :list-id id)

    (ll-member-destroy/json *cred* :list-id id
                            :screen-name (assoc-ref *settings* 'user2))

    ;; cleanup list
    (ll-destroy/json *cred* :list-id id)))

;; TODO geo api
;; TODO streaming api

(test!! "rate limit user1"
  (help-rate-limit-status/json *cred*))

(test!! "account credentials"
  (account-verify-credentials? *cred*))

(define (random-color)
  (string-pad (number->string (random-integer #x1000000) 16) 6 #\0))

(test!! "update profile color"
  (account-update-profile-colors/json
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

(test!! "update profile image"
  (account-update-profile-image/json *cred* (random-mini-picture)))

(test!! "update profile background image"
  (account-update-profile-background-image/json *cred* (random-big-picture) :tile #t))

(test-end :exit-on-failure #t)
