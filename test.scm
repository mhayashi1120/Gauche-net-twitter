;;;
;;; Test net.twitter
;;;

(use gauche.test)

(test-start "net.twitter")
(use net.twitter)
(test-module 'net.twitter)

(use util.list)
(use file.util)
(use rfc.uri)
(use rfc.http)

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

;; exercise

(test* "help test"
       #t
       (and (twitter-help-test/sxml *cred*) #t))

(test* "help configuration"
       #t
       (and (twitter-help-configuration/sxml *cred*) #t))

(test* "help languages"
       #t
       (and (twitter-help-languages/sxml *cred*) #t))

(use srfi-19)
(use sxml.sxpath)

(test* "show user"
       #t
       (and (twitter-user-show/sxml *cred* :id (assoc-ref *settings* 'user)) #t))

(let ((msg (string-append "マルチバイト文字と日付 " (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
      (user-id #f)
      (id #f))

  (test* "update status"
         #t
         (and (set! id (twitter-update *cred* msg)) #t))
  
  (test* "show status"
         msg
         ((if-car-sxpath '(status text *text*)) (twitter-show/sxml *cred* id)))

  (test* "fetching user info"
         #t
         (and 
          (set! user-id 
                (let1 sxml (twitter-user-show/sxml *cred* :id (assoc-ref *settings* 'user))
                  ((if-car-sxpath '(user id *text*)) sxml)))
          #t))

  (test* "fetching timeline by id"
         #t
         (and (twitter-user-timeline/sxml #f :id (assoc-ref *settings* 'user)) #t))

  (test* "fetching timeline by user-id"
         #t
         (and (twitter-user-timeline/sxml #f :user-id user-id) #t))

  (test* "fetching public timeline"
         #t
         (and (twitter-public-timeline/sxml) #t))

  (test* "fetching home timeline"
         #t
         (and (twitter-home-timeline/sxml *cred*) #t))

  (test* "fetching mentions"
         #t
         (and (twitter-mentions/sxml *cred*) #t))
  
  (test* "searching"
         #t
         (and (twitter-search/sxml (assoc-ref *settings* 'user)) #t))

  (test* "creating friendships"
         #t
         (begin
           (twitter-friendship-create/sxml *cred* (assoc-ref *settings* 'user2))
           (twitter-friendship-create/sxml *cred2* (assoc-ref *settings* 'user))
           #t))

  (let ((msg (string-append "direct message" (date->string (current-date) "~Y-~m-~d ~H:~M:~S")))
        (id #f))

    (set! id 
          ((if-car-sxpath '(// id *text*)) 
           (twitter-direct-message-new/sxml *cred* (assoc-ref *settings* 'user2) msg)))

    (test* "sent direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (twitter-direct-messages-sent/sxml *cred*)))

    (test* "received direct message"
           msg
           ((if-car-sxpath '(// text *text*)) (twitter-direct-messages/sxml *cred2*)))

    (test* "destroying direct message"
           #t
           (and (twitter-direct-message-destroy/sxml *cred* id) #t)))

  (test* "destroying friendships"
         #t
         (begin
           (twitter-friendship-destroy/sxml *cred* (assoc-ref *settings* 'user2))
           (twitter-friendship-destroy/sxml *cred2* (assoc-ref *settings* 'user))
           #t))

  (test* "deleting status"
         #t
         (and (twitter-destroy/sxml *cred* id) #t))
   
  )

(test-start "net.favotter")
(use net.favotter)
(test-module 'net.favotter)

(test-end)





