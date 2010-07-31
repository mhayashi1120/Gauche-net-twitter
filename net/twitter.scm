;;;
;;; Twitter access module
;;;

(define-module net.twitter
  (use rfc.http)
  (use rfc.sha)
  (use rfc.hmac)
  (use rfc.base64)
  (use rfc.uri)
  (use rfc.822)
  (use rfc.mime)
  (use srfi-1)
  (use srfi-13)
  (use www.cgi)
  (use math.mt-random)
  (use gauche.uvector)
  (use gauche.version)
  (use gauche.experimental.ref)         ; for '~'.  remove after 0.9.1
  (use text.tree)
  (use text.tr)
  (use util.list)
  (use util.match)
  (use sxml.ssax)
  (use sxml.sxpath)
  (export <twitter-cred> <twitter-api-error>
          twitter-authenticate-client
          
          twitter-public-timeline/sxml
          twitter-home-timeline/sxml
          twitter-friends-timeline/sxml
          twitter-user-timeline/sxml
          twitter-mentions/sxml twitter-mentions

          twitter-show/sxml
          twitter-update/sxml twitter-update
          twitter-destroy/sxml
          twitter-retweet/sxml
          twitter-retweets/sxml
          twitter-retweeted-by/sxml
          twitter-retweeted-by-ids/sxml

          twitter-user-show/sxml
          twitter-user-lookup/sxml
          twitter-user-search/sxml
          twitter-friends/sxml
          twitter-friends/ids twitter-friends/ids/sxml
          twitter-followers/sxml
          twitter-followers/ids/sxml twitter-followers/ids

          twitter-retweeted-to-me/sxml twitter-retweeted-by-me/sxml twitter-retweets-of-me/sxml
          twitter-follow twitter-unfollow
          twitter-lists/sxml twitter-list-show/sxml
          twitter-list-statuses/sxml twitter-list-memberships/sxml twitter-list-subscriptions/sxml
          twitter-list-create/sxml twitter-list-destroy/sxml twitter-list-update/sxml
          twitter-list-create
          twitter-list-members/sxml twitter-list-members-show/sxml
          twitter-list-members-add/sxml twitter-list-members-delete/sxml
          twitter-list-subscribers/sxml twitter-list-subscribers-show/sxml
          twitter-list-subscribers-add/sxml twitter-list-subscribers-delete/sxml
          ))
(select-module net.twitter)

;; OAuth related stuff.
;; These may be factored out into net.oauth module someday.
;; References to the section numbers refer to http://oauth.net/core/1.0/.

;; Returns query parameters with calculated "oauth_signature"
(define (oauth-add-signature method request-url params consumer-secret
                             :optional (token-secret ""))
  `(,@params
    ("oauth_signature" ,(oauth-signature method request-url params
                                         consumer-secret token-secret))))

;; Calculate signature.
(define (oauth-signature method request-url params consumer-secret
                         :optional (token-secret ""))
  (base64-encode-string
   (hmac-digest-string (oauth-signature-base-string method request-url params)
                       :key #`",|consumer-secret|&,|token-secret|"
                       :hasher <sha1>)))

;; Construct signature base string. (Section 9.1)
(define (oauth-signature-base-string method request-url params)
  (define (param-sorter a b)
    (or (string<? (car a) (car b))
        (and (string=? (car a) (car b))
             (string<? (cadr a) (cadr b)))))
  (string-append
   (string-upcase method) "&"
   (oauth-uri-encode (oauth-normalize-request-url request-url)) "&"
   (oauth-uri-encode (oauth-compose-query (sort params param-sorter)))))

;; Oauth requires hex digits in %-encodings to be upper case (Section 5.1)
;; The following two routines should be used instead of uri-encode-string
;; and http-compose-query to conform that.
(define (oauth-uri-encode str)
  (%-fix (uri-encode-string str :encoding 'utf-8)))

(define (oauth-compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))


;; Normalize request url.  (Section 9.1.2)
(define (oauth-normalize-request-url url)
  (receive (scheme userinfo host port path query frag) (uri-parse url)
    (tree->string `(,(string-downcase scheme) "://"
                    ,(if userinfo `(,(string-downcase userinfo) "@") "")
                    ,(string-downcase host)
                    ,(if (or (not port)
                             (and (string-ci=? scheme "http")
                                  (equal? port "80"))
                             (and (string-ci=? scheme "https")
                                  (equal? port "443")))
                       ""
                       `(":" ,port))
                    ,path))))

;; Reqest either request token or access token.
(define (oauth-request method request-url params consumer-secret
                       :optional (token-secret ""))
  (define (add-sign meth)
    (oauth-add-signature meth request-url params consumer-secret token-secret))
  (receive (scheme specific) (uri-scheme&specific request-url)
    ;; https is supported since 0.9.1
    (define secure-opt
      (cond [(equal? scheme "http") '()]
            [(equal? scheme "https")
             (if (version>? (gauche-version) "0.9") `(:secure #t) '())]
            [else (error "oauth-request: unsupported scheme" scheme)]))
    (receive (auth path query frag) (uri-decompose-hierarchical specific)
      (receive (status header body)
          (cond [(equal? method "GET")
                 (apply http-get auth
                        #`",|path|?,(oauth-compose-query (add-sign \"GET\"))"
                        secure-opt)]
                [(equal? method "POST")
                 (apply http-post auth path
                        (oauth-compose-query (add-sign "POST"))
                        secure-opt)]
                [else (error "oauth-request: unsupported method" method)])
        (unless (equal? status "200")
          (errorf "oauth-request: service provider responded ~a: ~a"
                  status body))
        (cgi-parse-parameters :query-string body)))))

(define (timestamp) (number->string (sys-time)))

(define oauth-nonce
  (let ([random-source (make <mersenne-twister>
                         :seed (* (sys-time) (sys-getpid)))]
        [v (make-u32vector 10)])
    (lambda ()
      (mt-random-fill-u32vector! random-source v)
      (digest-hexify (sha1-digest-string (x->string v))))))

;; Returns a header field suitable to pass as :authorization header
;; for http-post/http-get.
(define (oauth-auth-header method request-url params
                           consumer-key consumer-secret
                           access-token access-token-secret)
  (let* ([auth-params `(("oauth_consumer_key" ,consumer-key)
                        ("oauth_nonce" ,(oauth-nonce))
                        ("oauth_signature_method" "HMAC-SHA1")
                        ("oauth_timestamp" ,(timestamp))
                        ("oauth_token" ,access-token))]
         [signature (oauth-signature
                     method request-url
                     `(,@auth-params ,@params)
                     consumer-secret
                     access-token-secret)])
    (format "OAuth ~a"
            (string-join (map (cut string-join <> "=")
                              `(,@auth-params
                                ("oauth_signature"
                                 ,(oauth-uri-encode signature))))
                         ", "))))

;;
;; A convenience macro to construct query parameters, skipping
;; if #f is given to the variable.
;;

(define-macro (make-query-params . vars)
  `(cond-list
    ,@(map (lambda (v)
             `(,v `(,',(string-tr (x->string v) "-" "_") ,(param->string ,v))))
           vars)))

(define (param->string v)
  (cond
   [(eq? v #t) "t"]
   [else (x->string v)]))

;;;
;;; Public API
;;;

;;
;; Credential
;;
(define-class <twitter-cred> ()
  ((consumer-key :init-keyword :consumer-key)
   (consumer-secret :init-keyword :consumer-secret)
   (access-token :init-keyword :access-token)
   (access-token-secret :init-keyword :access-token-secret)))

;;
;; Condition for error response
;;
(define-condition-type <twitter-api-error> <error> #f
  (status #f)
  (headers #f)
  (body #f)
  (body-sxml #f))

;;
;; Authenticate the client using OAuth PIN-based authentication flow.
;;
(define (twitter-authenticate-client consumer-key consumer-secret
                                     :optional (input-callback
                                                default-input-callback))
  (let* ([r-response
          (oauth-request "GET" "http://api.twitter.com/oauth/request_token"
                         `(("oauth_consumer_key" ,consumer-key)
                           ("oauth_nonce" ,(oauth-nonce))
                           ("oauth_signature_method" "HMAC-SHA1")
                           ("oauth_timestamp" ,(timestamp))
                           ("oauth_version" "1.0"))
                         consumer-secret)]
	 [r-token  (cgi-get-parameter "oauth_token" r-response)]
	 [r-secret (cgi-get-parameter "oauth_token_secret" r-response)])
    (unless (and r-token r-secret)
      (error "failed to obtain request token"))
    (if-let1 oauth-verifier
        (input-callback
         #`"https://api.twitter.com/oauth/authorize?oauth_token=,r-token")
      (let* ([a-response
              (oauth-request "POST" "http://api.twitter.com/oauth/access_token"
                             `(("oauth_consumer_key" ,consumer-key)
                               ("oauth_nonce" ,(oauth-nonce))
                               ("oauth_signature_method" "HMAC-SHA1")
                               ("oauth_timestamp" ,(timestamp))
                               ("oauth_token" ,r-token)
                               ("oauth_verifier" ,oauth-verifier))
                             r-secret)]
             [a-token (cgi-get-parameter "oauth_token" a-response)]
             [a-secret (cgi-get-parameter "oauth_token_secret" a-response)])
        (make <twitter-cred>
          :consumer-key consumer-key
          :consumer-secret consumer-secret
          :access-token a-token
          :access-token-secret a-secret))
      #f)))

;;
;; Timeline methods
;;
(define (twitter-public-timeline/sxml :key (trim-user #f) (include-entities #f))
  (call/oauth->sxml #f 'get "/1/statuses/public_timeline.xml"
                    (make-query-params trim-user include-entities)))

(define (twitter-home-timeline/sxml cred :key (since-id #f) (max-id #f)
                                              (count #f) (page #f)
                                              (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/home_timeline.xml"
                    (make-query-params since-id max-id count page
                                       trim-user include-entities)))

(define (twitter-friends-timeline/sxml cred :key (since-id #f) (max-id #f)
                                                 (count #f) (page #f)
                                                 (trim-user #f) (include-rts #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/friends_timeline.xml"
                    (make-query-params since-id max-id count page
                                       trim-user include-rts include-entities)))

(define (twitter-user-timeline/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                              (since-id #f) (max-id #f)
                                              (count #f) (page #f)
                                              (trim-user #f) (include-rts #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/user_timeline.xml"
                    (make-query-params id user-id screen-name since-id max-id count page
                                       trim-user include-rts include-entities)))

(define (twitter-mentions/sxml cred :key (since-id #f) (max-id #f)
                                         (count #f) (page #f)
                                         (trim-user #f) (include-rts #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/statuses/mentions.xml"
                    (make-query-params since-id max-id count page
                                       trim-user include-rts include-entities)))

;; Returns list of (tweet-id text user-screen-name user-id)
(define (twitter-mentions cred . args)
  (let ([r (values-ref (apply twitter-mentions/sxml cred args) 0)]
        [accessors `(,(if-car-sxpath '(id *text*))
                     ,(if-car-sxpath '(text *text*))
                     ,(if-car-sxpath '(user screen_name *text*))
                     ,(if-car-sxpath '(user id *text*)))])
    (sort-by (map (lambda (s) (map (cut <> s) accessors))
                  ((sxpath '(// status)) r))
             (.$ x->integer car)
             >)))

;;
;; Status method
;;

;; cred can be #f to view public tweet.
(define (twitter-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/statuses/show/,|id|.xml" '()))

(define (twitter-update/sxml cred message :key (in-reply-to-status-id #f)
                                               (lat #f) (long #f) (place-id #f)
                                               (display-coordinates #f))
  (call/oauth->sxml cred 'post "/1/statuses/update.xml"
                    `(("status" ,message)
                      ,@(make-query-params in-reply-to-status-id lat long
                                           place-id display-coordinates))))

;; Returns tweet id on success
(define (twitter-update cred message . opts)
  ((if-car-sxpath '(// status id *text*))
   (values-ref (apply twitter-update/sxml cred message opts) 0)))

(define (twitter-follow cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/create/,|id|.xml" '()))

(define (twitter-unfollow cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/destroy/,|id|.xml" '()))

(define (twitter-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/destroy/,|id|.xml" '()))

(define (twitter-retweet/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/statuses/retweet/,|id|.xml" '()))

(define (twitter-retweets/sxml cred id :key (count #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets/,|id|.xml"
                    (make-query-params count)))

(define (twitter-retweeted-by/sxml cred id :key (count #f) (page #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by.xml"
                    (make-query-params count page)))

(define (twitter-retweeted-by-ids/sxml cred id :key (count #f) (page #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/,|id|/retweeted_by/ids.xml"
                    (make-query-params count page)))

(define (twitter-retweeted-to-me/sxml cred :key (count #f) (page #f) (max_id #f) (since_id #f)
                                      (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_to_me.xml"
                    (make-query-params count page max_id since_id trim-user include-entities)))

(define (twitter-retweeted-by-me/sxml cred :key (count #f) (page #f) (max_id #f) (since_id #f)
                                      (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_by_me.xml"
                    (make-query-params count page max_id since_id trim-user include-entities)))

(define (twitter-retweets-of-me/sxml cred :key (count #f) (page #f) (max_id #f) (since_id #f)
                                     (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets_of_me.xml"
                    (make-query-params count page max_id since_id trim-user include-entities)))

;;
;; List methods
;;

;; user is user-id or screen-name
(define (twitter-lists/sxml cred user :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/lists.xml"
                    (make-query-params cursor)))

;; list is list-id or list-name
(define (twitter-list-show/sxml cred user list :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/lists/,|list|.xml"
                    (make-query-params cursor)))

(define (twitter-list-statuses/sxml cred user list :key (since-id #f) (max-id #f)
                                        (per-page #f) (page #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/lists/,|list|/statuses.xml"
                    (make-query-params since-id max-id per-page page)))

(define (twitter-list-memberships/sxml cred user :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/lists/memberships.xml"
                    (make-query-params cursor)))

(define (twitter-list-subscriptions/sxml cred user :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/lists/subscriptions.xml"
                    (make-query-params cursor)))

;; mode is private or public
(define (twitter-list-create/sxml cred user name :key (mode #f) (description #f))
  (call/oauth->sxml cred 'post #`"/1/,|user|/lists.xml"
                    (make-query-params name mode description)))

;; Returns list id on success
(define (twitter-list-create cred user name . opts)
  ((if-car-sxpath '(list id *text*))
   (values-ref (apply twitter-list-create/sxml cred user name opts) 0)))

;; mode is private or public
(define (twitter-list-update/sxml cred user name :key (mode #f) (description #f))
  (call/oauth->sxml cred 'post #`"/1/,|user|/lists/,|name|.xml"
                    (make-query-params mode description)))

(define (twitter-list-destroy/sxml cred user name)
  (let1 -method "DELETE"
    (call/oauth->sxml cred 'post #`"/1/,|user|/lists/,|name|.xml"
                      (make-query-params -method))))

(define (twitter-list-members/sxml cred user list-name :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/,|list-name|/members.xml"
                    (make-query-params cursor)))

(define (twitter-list-members-show/sxml cred user list-name id)
  (call/oauth->sxml cred 'get #`"/1/,|user|/,|list-name|/members/,|id|.xml" '()))

(define (twitter-list-members-add/sxml cred user list-name id)
  (call/oauth->sxml cred 'post #`"/1/,|user|/,|list-name|/members.xml"
                    (make-query-params id)))

(define (twitter-list-members-delete/sxml cred user list-name id)
  (let1 -method "DELETE"
    (call/oauth->sxml cred 'post #`"/1/,|user|/,|list-name|/members.xml"
                      (make-query-params -method id))))

(define (twitter-list-subscribers/sxml cred user list-name :key (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/,|user|/,|list-name|/subscribers.xml"
                    (make-query-params cursor)))

(define (twitter-list-subscribers-show/sxml cred user list-name id)
  (call/oauth->sxml cred 'get #`"/1/,|user|/,|list-name|/subscribers/,|id|.xml" '()))

(define (twitter-list-subscribers-add/sxml cred user list-name id)
  (call/oauth->sxml cred 'post #`"/1/,|user|/,|list-name|/subscribers.xml"
                    (make-query-params id)))

(define (twitter-list-subscribers-delete/sxml cred user list-name id)
  (let1 -method "DELETE"
    (call/oauth->sxml cred 'post #`"/1/,|user|/,|list-name|/subscribers.xml"
                      (make-query-params -method id))))

;;
;; User methods
;;

;; cred can be #f.
(define (twitter-user-show/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'get #`"/1/users/show.xml"
                    (make-query-params id user-id screen-name)))
  
(define (twitter-user-lookup/sxml cred :key (user-ids '()) (screen-names '()))
  (call/oauth->sxml cred 'post #`"/1/users/lookup.xml"
                    (cond-list [(not (null? user-ids))
                                `("user-id" ,(string-join user-ids ","))]
                               [(not (null? screen-names))
                                `("screen-name" ,(string-join screen-names ","))]
                               )))

(define (twitter-user-search/sxml cred q :key (per-page #f) (page #f))
  (call/oauth->sxml cred 'get "/1/users/search.xml"
                    (make-query-params q per-page page)))

;; CRED can be #f
(define (twitter-friends/sxml cred :key (id #f) (user-id #f)
                                        (screen-name #f) (cursor #f))
  (call/oauth->sxml cred 'get "/1/statuses/friends.xml"
                    (make-query-params id user-id screen-name cursor)))

(define (twitter-friends/ids/sxml cred :key (id #f) (user-id #f)
                                  (screen-name #f)
                                  (cursor #f))
  (call/oauth->sxml cred 'get "/1/friends/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns list of user ids
(define (twitter-friends/ids cred :key (id #f) (user-id #f)
                             (screen-name #f))
  (retrieve-followers/friends twitter-friends/ids/sxml
                              cred :id id :user-id user-id
                              :screen-name screen-name))

(define (twitter-followers/sxml cred :key (id #f) (user-id #f)
                                (screen-name #f) (cursor #f))
  (call/oauth->sxml cred 'get "/1/statuses/followers.xml"
                    (make-query-params id user-id screen-name cursor)))

(define (twitter-followers/ids/sxml cred :key (id #f) (user-id #f)
                                    (screen-name #f)
                                    (cursor #f))
  (call/oauth->sxml cred 'get "/1/followers/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns ids of *all* followers; paging is handled automatically.
(define (twitter-followers/ids cred :key (id #f) (user-id #f)
                               (screen-name #f))
  (retrieve-followers/friends twitter-followers/ids/sxml
                              cred :id id :user-id user-id
                              :screen-name screen-name))

;;;
;;; Internal utilities
;;;

(define (retrieve-followers/friends f . args)
  (let loop ((cursor "-1") (ids '()))
    (let* ([r (apply f (append args (list :cursor cursor)))]
           [next ((if-car-sxpath '(// next_cursor *text*)) r)]
           [ids (cons ((sxpath '(// id *text*)) r) ids)])
      (if (equal? next "0")
          (concatenate (reverse ids))
        (loop next ids)))))

(define (default-input-callback url)
  (print "Open the following url and type in the shown PIN.")
  (print url)
  (let loop ()
    (display "Input PIN: ") (flush)
    (let1 pin (read-line)
      (cond [(eof-object? pin) #f]
            [(string-null? pin) (loop)]
            [else pin]))))

(define (check-api-error status headers body)
  (unless (equal? status "200")
    (or (and-let* ([ct (rfc822-header-ref headers "content-type")])
          (match (mime-parse-content-type ct)
            [(_ "xml" . _)
             (let1 body-sxml
                 (call-with-input-string body (cut ssax:xml->sxml <> '()))
               (error <twitter-api-error>
                      :status status :headers headers :body body
                      :body-sxml body-sxml
                      (or ((if-car-sxpath '(// error *text*)) body-sxml)
                          body)))]
            [_ #f]))
        (error <twitter-api-error>
               :status status :headers headers :body body
               :body-sxml #f body))))

(define (call/oauth->sxml cred method path params . opts)

  (define (call)
    (if cred
      (let1 auth (oauth-auth-header
                  (if (eq? method 'get) "GET" "POST")
                  #`"http://api.twitter.com,|path|" params
                  (~ cred'consumer-key) (~ cred'consumer-secret)
                  (~ cred'access-token) (~ cred'access-token-secret))
        (case method
          [(get) (apply http-get "api.twitter.com"
                        #`",|path|?,(oauth-compose-query params)"
                        :Authorization auth opts)]
          [(post) (apply http-post "api.twitter.com" path
                         (oauth-compose-query params)
                         :Authorization auth opts)]))
      (case method
          [(get) (apply http-get "api.twitter.com"
                        #`",|path|?,(oauth-compose-query params)" opts)]
          [(post) (apply http-post "api.twitter.com" path
                         (oauth-compose-query params) opts)])))

  (define (retrieve status headers body)
    (check-api-error status headers body)
    (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
            headers))

  (call-with-values call retrieve))
