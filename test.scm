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

(define *cred*
  (let ((settings
         (with-input-from-file ".test-settings.scm"
           read)))
    ;; (twitter-authenticate-client
    ;;  (assoc-ref settings 'consumer-key)
    ;;  (assoc-ref settings 'consumer-secret-key)
    ;;  (lambda (url)
    ;;    (receive (scheme user-info host port path query fragment)
    ;;        (uri-parse url)
    ;;      (receive (code headers body)
    ;;          (http-get host #`",|path|?,|query|"
    ;;                    :secure #t
    ;;                    ;;TODO not supported yet
    ;;                    :auth-user (assoc-ref settings 'user)
    ;;                    :auth-password (assoc-ref settings 'password))
    ;;        (if-let1 m (#/<code>([0-9]+)<\/code>/ body)
    ;;          (begin
    ;;            (m 1))
    ;;          #f)))))

    ;; Delete after rfc.http auth-user implemented
    (define (from-token key)
      (assq-ref (assq-ref settings 'oauth-token) key))

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


(test-start "net.favotter")
(use net.favotter)
(test-module 'net.favotter)

(test-end)





