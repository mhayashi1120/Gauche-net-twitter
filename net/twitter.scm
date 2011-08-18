;;;
;;; Twitter access module
;;;

(define-module net.twitter
  (use rfc.http)
  (use rfc.uri)
  (use rfc.822)
  (use rfc.mime)
  (use srfi-1)
  (use srfi-13)
  (use gauche.experimental.ref)         ; for '~'.  remove after 0.9.1
  (use text.tr)
  (use util.list)
  (use util.match)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use rfc.json)
  (use net.oauth)
  (export <twitter-cred> <twitter-api-error>
          twitter-authenticate-client
          twitter-authenticate-request
          twitter-authorize
          twitter-authorize-url

          twitter-public-timeline/sxml
          twitter-home-timeline/sxml
          twitter-user-timeline/sxml
          twitter-mentions/sxml twitter-mentions

          twitter-search/sxml

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
          twitter-user-suggestions/sxml
          twitter-user-suggestions/category/sxml

          twitter-friends/ids/sxml twitter-friends/ids
          twitter-followers/ids/sxml twitter-followers/ids

          twitter-retweeted-to-me/sxml
          twitter-retweeted-by-me/sxml
          twitter-retweets-of-me/sxml

          twitter-retweeted-to-user/sxml
          twitter-retweeted-by-user/sxml

          twitter-direct-messages/sxml
          twitter-direct-messages-sent/sxml
          twitter-direct-message-new/sxml
          twitter-direct-message-destroy/sxml

          twitter-friendship-show/sxml
          twitter-friendship-exists/sxml twitter-friendship-exists?
          twitter-friendship-create/sxml twitter-friendship-destroy/sxml
          twitter-friendship-incoming/sxml twitter-friendship-outgoing/sxml
          twitter-friendship-update/sxml

          twitter-lists/sxml
          twitter-lists/ids twitter-lists/slugs
          twitter-list-show/sxml
          twitter-list-statuses/sxml
          twitter-list-create/sxml
          twitter-list-create
          twitter-list-update/sxml
          twitter-list-destroy/sxml
          twitter-list-members/sxml
          twitter-list-member-show/sxml
          twitter-list-member-create/sxml
          twitter-list-members-create-all/sxml
          twitter-list-member-destroy/sxml
          twitter-list-members/ids
          twitter-list-subscribers/sxml
          twitter-list-subscriber-show/sxml
          twitter-list-subscriber-create/sxml
          twitter-list-subscriber-destroy/sxml
          twitter-list-subscribers/ids
          twitter-list-subscriptions/sxml twitter-list-subscriptions/ids
          twitter-list-memberships/sxml twitter-list-memberships/ids

          twitter-favorites/sxml
          twitter-favorite-create/sxml
          twitter-favorite-destroy/sxml

          twitter-account-verify-credentials/sxml
          twitter-account-totals/sxml
          twitter-account-settings/sxml
          twitter-account-settings-update/sxml
          twitter-account-rate-limit-status/sxml
          twitter-account-update-profile-image/sxml
          twitter-account-update-profile-background-image/sxml
          twitter-account-update-profile-colors/sxml
          twitter-account-update-profile/sxml
          twitter-account-verify-credentials?

          twitter-notifications-follow/sxml
          twitter-notifications-leave/sxml

          twitter-blocks/sxml
          twitter-blocks/ids/sxml
          twitter-block-create/sxml
          twitter-block-destroy/sxml
          twitter-block-exists/sxml
          twitter-block-exists?
          twitter-blocks/ids

          twitter-report-spam/sxml

          twitter-saved-searches/sxml
          twitter-saved-search-show/sxml
          twitter-saved-search-create/sxml
          twitter-saved-search-destroy/sxml

          twitter-trends-available/sxml twitter-trends-location/sxml

          twitter-legal-tos/sxml twitter-legal-privacy/sxml

          twitter-help-test/sxml
          twitter-help-languages/sxml twitter-help-configuration/sxml

          twitter-open-stream
          ))
(select-module net.twitter)

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

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
  (body-sxml #f)
  (body-json #f))

;;
;; OAuth authorization flow
;;

(define twitter-authenticate-request 
  (oauth-authenticate-sender "http://api.twitter.com/oauth/request_token"))

(define twitter-authorize-url 
  (oauth-authenticate-url "https://api.twitter.com/oauth/authorize"))

(define twitter-authorize
  (oauth-authorizer "http://api.twitter.com/oauth/access_token"))

;; Authenticate the client using OAuth PIN-based authentication flow.
(define twitter-authenticate-client
  (oauth-client-authenticator 
   twitter-authenticate-request twitter-authorize-url  twitter-authorize))

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
;; Search API method
;;

(define (twitter-search/sxml q :key (lang #f) (locale #f) 
                             (rpp #f) (page #f)
                             (since-id #f) (until #f) (geocode #f)
                             (show-user #f) (result-type #f)
                             (max-id #f) (since #f) ; deprecated
                             )
  (let1 params (make-query-params q lang locale rpp
                                  page since-id until geocode
                                  show-user result-type)
    (define (call)
      (http-get "search.twitter.com" #`"/search.atom?,(compose-query params)"))
  
    (define (retrieve status headers body)
      (check-api-error status headers body)
      (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
              headers))

    (call-with-values call retrieve)))

;;
;; Status method
;;

;; cred can be #f to view public tweet.
(define (twitter-show/sxml cred id :key (include-entities #f) (trim-user #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/show/,|id|.xml" 
					(make-query-params include-entities trim-user)))

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

(define (twitter-retweeted-to-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                                      (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_to_me.xml"
                    (make-query-params count page max-id since-id trim-user include-entities)))

(define (twitter-retweeted-by-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                                      (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_by_me.xml"
                    (make-query-params count page max-id since-id trim-user include-entities)))

(define (twitter-retweets-of-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                                     (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets_of_me.xml"
                    (make-query-params count page max-id since-id trim-user include-entities)))

(define (twitter-retweeted-to-user/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                        (count #f) (page #f) (max-id #f) (since-id #f)
                                        (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_to_user.xml"
                    (make-query-params id user-id screen-name 
                                       count page max-id since-id trim-user include-entities)))

(define (twitter-retweeted-by-user/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                        (count #f) (page #f) (max-id #f) (since-id #f)
                                        (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_by_user.xml"
                    (make-query-params id user-id screen-name 
                                       count page max-id since-id trim-user include-entities)))

;;
;; Directmessage methods
;;

(define (twitter-direct-messages/sxml cred :key (count #f) (page #f) (max_id #f) (since-id #f))
  (call/oauth->sxml cred 'get #`"/1/direct_messages.xml"
                    (make-query-params count page max_id since-id)))

(define (twitter-direct-messages-sent/sxml cred :key
                                           (count #f) (page #f) 
                                           (max_id #f) (since-id #f))
  (call/oauth->sxml cred 'get #`"/1/direct_messages/sent.xml"
                    (make-query-params count page max_id since-id)))

(define (twitter-direct-message-new/sxml cred user text)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/new.xml"
                    (make-query-params user text)))

(define (twitter-direct-message-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/direct_messages/destroy.xml"
                    (make-query-params id)))


;;
;; Friendship methods
;;

(define (twitter-friendship-show/sxml cred :key (source-id #f) (source-screen-name #f)
                                      (target-id #f) (target-screen-name #f))
  (call/oauth->sxml cred 'get #`"/1/friendships/show.xml"
                    (make-query-params source-id source-screen-name
                                       target-id target-screen-name)))

(define (twitter-friendship-exists/sxml cred user-a user-b)
  (call/oauth->sxml cred 'get #`"/1/friendships/exists.xml"
                    (make-query-params user-a user-b)))

(define (twitter-friendship-exists? cred user-a user-b)
  (string=?
   ((if-car-sxpath '(friends *text*))
    (values-ref (twitter-friendship-exists/sxml cred user-a user-b) 0))
   "true"))

(define (twitter-friendship-create/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/create/,|id|.xml" '()))

(define (twitter-friendship-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/friendships/destroy/,|id|.xml" '()))

(define (twitter-friendship-incoming/sxml cred cursor)
  (call/oauth->sxml cred 'get #`"/1/friendships/incoming.xml"
                    (make-query-params cursor)))

(define (twitter-friendship-outgoing/sxml cred cursor)
  (call/oauth->sxml cred 'get #`"/1/friendships/outgoing.xml"
                    (make-query-params cursor)))

(define (twitter-friendship-update/sxml cred screen-name :key (device #f)
                                        (retweets #f))
  (call/oauth->sxml cred 'post #`"/1/friendships/update.xml" 
                    (make-query-params screen-name device retweets)))

;;
;; List methods
;;

;; require user-id or screen-name
(define (twitter-lists/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                            (cursor #f))
  (call/oauth->sxml cred 'get "/1/lists.xml"
                    (make-query-params id user-id screen-name cursor)))

;; args are passed to twitter-lists/sxml
(define (twitter-lists/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*))
         twitter-lists/sxml cred args))

;; args are passed to twitter-lists/sxml
(define (twitter-lists/slugs cred . args)
  (apply retrieve-stream (sxpath '(// list name *text*))
         twitter-lists/sxml cred args))

;; (or list-id (and slug (or owner-id owner-screen-name)))
(define (twitter-list-show/sxml cred :key (list-id #f) 
                                (slug #f) (owner-id #f) (owner-screen-name #f))
  (call/oauth->sxml cred 'get "/1/lists/show.xml"
                    (make-query-params list-id slug owner-id owner-screen-name)))

(define (twitter-list-statuses/sxml cred :key (list-id #f)
                                    (slug #f) (owner-id #f) (owner-screen-name #f)
                                    (since-id #f) (max-id #f)
                                    (per-page #f) (page #f)
                                    (include-entities #f) (include-rts #f))
  (call/oauth->sxml cred 'get "/1/lists/statuses.xml"
                    (make-query-params list-id 
                                       slug owner-id owner-screen-name
                                       since-id max-id per-page page
                                       include-entities include-rts)))

;; mode is private or public
(define (twitter-list-create/sxml cred name :key (mode #f) (description #f))
  (call/oauth->sxml cred 'post "/1/lists/create.xml"
                    (make-query-params name mode description)))

;; Returns list id when succeeded
(define (twitter-list-create cred name . opts)
  ((if-car-sxpath '(list id *text*))
   (values-ref (apply twitter-list-create/sxml cred name opts) 0)))

;; mode is private or public
(define (twitter-list-update/sxml cred :key (list-id #f)
                                  (slug #f) (owner-id #f) (owner-screen-name #f)
                                  (name #f) (mode #f) (description #f))
  (call/oauth->sxml cred 'post "/1/lists/update.xml"
                    (make-query-params list-id slug owner-id owner-screen-name
                                       name mode description)))

(define (twitter-list-destroy/sxml cred :key (list-id #f) 
                                   (slug #f) (owner-id #f) (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/destroy.xml"
                    (make-query-params list-id slug owner-id owner-screen-name)))

(define (twitter-list-members/sxml cred :key (list-id #f) 
                                   (slug #f) (owner-id #f) (owner-screen-name #f)
                                   (cursor #f) (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/members.xml"
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       cursor include-entities skip-status)))

(define (twitter-list-member-show/sxml cred :key (list-id #f)
                                       (slug #f) (owner-id #f) (owner-screen-name #f)
                                       (user-id #f) (screen-name #f)
                                       (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/members/show.xml" 
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       user-id screen-name
                                       include-entities skip-status)))

(define (twitter-list-member-create/sxml cred :key (list-id #f)
                                         (slug #f) (owner-id #f) (owner-screen-name #f)
                                         (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/members/create.xml"
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       user-id screen-name)))

(define (twitter-list-members-create-all/sxml cred :key (list-id #f) 
                                              (slug #f) (owner-id #f)
                                              (owner-screen-name #f)
                                              (user-ids #f) (screen-names #f))
  (let ((user-id (and (pair? user-ids) (string-join user-ids ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->sxml cred 'post "/1/lists/members/create_all.xml"
                      (make-query-params list-id slug owner-id owner-screen-name 
                                         user-id screen-name))))

(define (twitter-list-member-destroy/sxml cred :key (list-id #f)
                                          (slug #f) (owner-id #f) (owner-screen-name #f)
                                          (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/members/destroy.xml"
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       user-id screen-name)))

;; args are passed to twitter-list-members/sxml
(define (twitter-list-members/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         twitter-list-members/sxml args))

(define (twitter-list-subscribers/sxml cred  :key (list-id #f) 
                                       (slug #f) (owner-id #f) (owner-screen-name #f)
                                       (cursor #f) (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/subscribers.xml"
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       cursor include-entities skip-status)))

(define (twitter-list-subscriber-show/sxml cred :key (list-id #f) 
                                           (slug #f) (owner-id #f) (owner-screen-name #f)
                                           (user-id #f) (screen-name #f)
                                           (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/subscribers/show.xml" 
                    (make-query-params list-id slug owner-id owner-screen-name 
                                       user-id screen-name)))

(define (twitter-list-subscriber-create/sxml cred :key (list-id #f) 
                                             (slug #f) (owner-id #f)
                                             (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/subscribers/create.xml"
                    (make-query-params list-id slug owner-id owner-screen-name)))

(define (twitter-list-subscriber-destroy/sxml cred :key (list-id #f) 
                                              (slug #f) (owner-id #f)
                                              (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/subscribers/destroy.xml"
                    (make-query-params list-id slug owner-id owner-screen-name)))

;; args are passed to twitter-list-subscribers/sxml
(define (twitter-list-subscribers/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         twitter-list-subscribers/sxml args))

(define (twitter-list-memberships/sxml cred :key (user-id #f) (screen-name #f) 
                                       (cursor #f) (filter-to-owned-lists #f))
  (call/oauth->sxml cred 'get #`"/1/lists/memberships.xml"
                    (make-query-params user-id screen-name
                                       filter-to-owned-lists cursor)))

;; args are passed to twitter-list-memberships/sxml 
(define (twitter-list-memberships/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*)) 
         twitter-list-memberships/sxml 
         cred args))

(define (twitter-list-subscriptions/sxml cred :key (user-id #f) (screen-name #f)
                                         (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/lists/subscriptions.xml"
                    (make-query-params user-id screen-name cursor)))

;; args are passed to twitter-list-subscriptions/sxml
(define (twitter-list-subscriptions/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*)) 
         twitter-list-subscriptions/sxml
         cred args))

;;
;; Favorites methods
;;

(define (twitter-favorites/sxml cred id :key (page #f)
                                (since-id #f) (include-entities #f)
                                (skip-status #f))
  (call/oauth->sxml cred 'get #`"/1/favorites.xml"
                    (make-query-params id page since-id
                                       include-entities skip-status)))

(define (twitter-favorite-create/sxml cred id :key (include-entities #f)
                                      (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/favorites/create/,|id|.xml" 
                    (make-query-params include-entities skip-status)))

(define (twitter-favorite-destroy/sxml cred id :key (include-entities #f)
                                       (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/favorites/destroy/,|id|.xml"
                    (make-query-params include-entities skip-status)))

;;
;; Account methods
;;

(define (twitter-account-verify-credentials/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/account/verify_credentials.xml" '()))

(define (twitter-account-verify-credentials? cred)
  (guard (e ((<twitter-api-error> e) #f))
    (twitter-account-verify-credentials/sxml cred)
    #t))

(define (twitter-account-totals/sxml cred)
  (call/oauth->sxml cred 'post "/1/account/totals.xml" '()))

(define (twitter-account-settings/sxml cred)
  (call/oauth->sxml cred 'get "/1/account/settings.xml" '()))

(define (twitter-account-settings-update/sxml cred :key (trend-location-woeid #f)
                                              (sleep-time-enabled #f)
                                              (start-sleep-time #f) (end-sleep-time #f)
                                              (time-zone #f) (lang #f))
  (call/oauth->sxml cred 'post "/1/account/settings.xml" 
                    (make-query-params trend-location-woeid sleep-time-enabled
                                       start-sleep-time end-sleep-time time-zone lang)))

(define (twitter-account-rate-limit-status/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/account/rate_limit_status.xml" '()))

(define (twitter-account-update-profile-image/sxml cred file :key
                                                   (include-entities #f)
                                                   (skip-status #f))
  (call/oauth-post-file->sxml cred #`"/1/account/update_profile_image.xml"
                              `((image :file ,file)
                                ,@(make-query-params
                                   include-entities skip-status))))

(define (twitter-account-update-profile-background-image/sxml cred file :key
                                                              (tile #f)
                                                              (include-entities #f)
                                                              (skip-status #f))
  (call/oauth-post-file->sxml cred #`"/1/account/update_profile_background_image.xml"
                              `((image :file ,file)
                                ,@(make-query-params 
                                   tile include-entities skip-status))))

;; ex: "000000", "000", "fff", "ffffff"
(define (twitter-account-update-profile-colors/sxml cred :key 
                                                    (profile-background-color #f)
                                                    (profile-text-color #f)
                                                    (profile-link-color #f)
                                                    (profile-sidebar-fill-color #f)
                                                    (profile-sidebar-border-color #f))
  (call/oauth->sxml cred 'post #`"/1/account/update_profile_colors.xml"
                    (make-query-params profile-background-color profile-text-color
                                       profile-link-color
                                       profile-sidebar-fill-color
                                       profile-sidebar-border-color)))

(define (twitter-account-update-profile/sxml cred :key (name #f)
                                             (url #f) (location #f)
                                             (description #f)
                                             (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/account/update_profile.xml"
                    (make-query-params name url location description
                                       include-entities skip-status)))

;;
;; User methods
;;

;; cred can be #f.
(define (twitter-user-show/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'get #`"/1/users/show.xml"
                    (make-query-params id user-id screen-name)))

(define (twitter-user-lookup/sxml cred :key (user-ids '()) (screen-names '())
                                  (include-entities #f) (skip-status #f))
  (let ((user-id (and (pair? user-ids) (string-join user-ids ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->sxml cred 'post #`"/1/users/lookup.xml"
                      (make-query-params user-id screen-name
                                         include-entities skip-status))))

(define (twitter-user-search/sxml cred q :key (per-page #f) (page #f)
                                  (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/users/search.xml"
                    (make-query-params q per-page page 
                                       include-entities skip-status)))

;; CRED can be #f
(define (twitter-user-suggestions/sxml cred :key (lang #f))
  (call/oauth->sxml cred 'get "/1/users/suggestions.xml" 
                    (make-query-params lang)))

;; CRED can be #f
(define (twitter-user-suggestions/category/sxml cred slug :key (lang #f))
  (call/oauth->sxml cred 'get #`"/1/users/suggestions/,|slug|.xml" 
                    (make-query-params lang)))

(define (twitter-friends/ids/sxml cred :key (id #f) (user-id #f)
                                  (screen-name #f)
                                  (cursor #f))
  (call/oauth->sxml cred 'get "/1/friends/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns list of user ids
(define (twitter-friends/ids cred :key (id #f) (user-id #f)
                             (screen-name #f))
  (retrieve-ids/sxml twitter-friends/ids/sxml
                     cred :id id :user-id user-id
                     :screen-name screen-name))

(define (twitter-followers/ids/sxml cred :key (id #f) (user-id #f)
                                    (screen-name #f)
                                    (cursor #f))
  (call/oauth->sxml cred 'get "/1/followers/ids.xml"
                    (make-query-params id user-id screen-name cursor)))

;; Returns ids of *all* followers; paging is handled automatically.
(define (twitter-followers/ids cred :key (id #f) (user-id #f)
                               (screen-name #f))
  (retrieve-ids/sxml twitter-followers/ids/sxml
                     cred :id id :user-id user-id
                     :screen-name screen-name))

;;
;; Notification methods
;;

(define (twitter-notifications-follow/sxml cred :key 
                                           (id #f) (user-id #f) (screen-name #f)
                                           (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/follow.xml"
                    (make-query-params id user-id screen-name
                                       include-entities skip-status)))

(define (twitter-notifications-leave/sxml cred :key
                                          (id #f) (user-id #f) (screen-name #f)
                                          (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/notifications/leave.xml"
                    (make-query-params id user-id screen-name
                                       include-entities skip-status)))

;;
;; Block methods
;;

(define (twitter-blocks/sxml cred :key (page #f))
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking.xml"
                    (make-query-params page)))

(define (twitter-blocks/ids/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/blocks/blocking/ids.xml" '()))

(define (twitter-block-create/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/blocks/create.xml"
                    (make-query-params id user-id screen-name)))

(define (twitter-block-destroy/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post #`"/1/blocks/destroy.xml"
                    (make-query-params id user-id screen-name)))

(define (twitter-block-exists/sxml cred :key (id #f) (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'get #`"/1/blocks/exists.xml"
                    (make-query-params id user-id screen-name)))

(define (twitter-block-exists? . args)
  (guard (e
          ((<twitter-api-error> e)
           ;;FIXME this message is not published API
           (if (string=? (ref e 'message) "You are not blocking this user.")
             #f
             (raise e))))
    (apply twitter-block-exists/sxml args)
    #t))

(define (twitter-blocks/ids cred)
  ((sxpath '(// id *text*)) (twitter-blocks/ids/sxml cred)))

;;
;; Report spam methods
;;

(define (twitter-report-spam/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                  (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'post #`"/1/report_spam.xml"
                    (make-query-params id user-id screen-name
                                       include-entities skip-status)))

;;
;; Saved search methods
;;

(define (twitter-saved-searches/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/saved_searches.xml" '()))

(define (twitter-saved-search-show/sxml cred id)
  (call/oauth->sxml cred 'get #`"/1/saved_searches/show/,|id|.xml" '()))

(define (twitter-saved-search-create/sxml cred query)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/create.xml" 
					(make-query-params query)))

(define (twitter-saved-search-destroy/sxml cred id)
  (call/oauth->sxml cred 'post #`"/1/saved_searches/destroy/,|id|.xml" '()))

;;
;; Trend methods
;;

;; CRED can be #f
(define (twitter-trends-available/sxml cred :key (lat #f) (long #f))
  (call/oauth->sxml cred 'get #`"/1/trends/available.xml"
                    (make-query-params lat long)))

;; CRED can be #f
(define (twitter-trends-location/sxml cred woeid)
  (call/oauth->sxml cred 'get #`"/1/trends/,|woeid|.xml" '()))

;;
;; Legal methods
;;

(define (twitter-legal-tos/sxml cred :key (lang #f))
  (call/oauth->sxml cred 'get "/1/legal/tos.xml" '()))

(define (twitter-legal-privacy/sxml cred :key (lang #f))
  (call/oauth->sxml cred 'get "/1/legal/privacy.xml" '()))

;;
;; Help methods
;;

(define (twitter-help-test/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/test.xml" '()))

(define (twitter-help-configuration/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/configuration.xml" '()))

(define (twitter-help-languages/sxml cred)
  (call/oauth->sxml cred 'get "/1/help/languages.xml" '()))

;;;
;;; Stream API
;;;

;; TODO http://practical-scheme.net/chaton/gauche/a/2011/02/11
;; proc accept one arg
(define (twitter-open-stream cred proc url params :key (raise-error? #f))

  (define (safe-parse-json string)
    ;; heading white space cause rfc.json parse error.
    (let1 trimmed (string-trim string)
      (and (> (string-length trimmed) 0)
           (parse-json-string trimmed))))

  (define (auth-header)
    (oauth-auth-header 
     "GET" url '()
     (~ cred'consumer-key) (~ cred'consumer-secret)
     (~ cred'access-token) (~ cred'access-token-secret)))

  (define (stream-looper code headers total retrieve)
    (check-stream-error code headers)
    (let loop ()
      (guard (e (else 
                 (when raise-error? (raise e))))
        (receive (port size) (retrieve)
          (and-let* ((s (read-string size port))
                     (json (safe-parse-json s)))
            (proc json))))
      (loop)))

  (define (parse-uri uri)
    (receive (scheme spec) (uri-scheme&specific uri)
      (receive (host path . rest) (uri-decompose-hierarchical spec)
        (values scheme host path))))

  (let1 auth (auth-header)
    (receive (scheme host path)
        (parse-uri url)
      (http-get host path
                :secure (string=? "https" scheme)
                :receiver stream-looper
                :Authorization auth))))

(define (check-stream-error status headers)
  (unless (equal? status "200")
    (error <twitter-api-error>
           :status status :headers headers
           "Failed opening stream")))

;;;
;;; Internal utilities
;;;

(define (retrieve-ids/sxml f . args)
  (apply retrieve-stream (sxpath '(// id *text*)) f args))

(define (retrieve-stream getter f . args)
  (let loop ((cursor "-1") (ids '()))
    (let* ([r (apply f (append args (list :cursor cursor)))]
           [next ((if-car-sxpath '(// next_cursor *text*)) r)]
           [ids (cons (getter r) ids)])
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

;; select body elements text
(define (parse-html-message body)
  (let loop ((lines (string-split body "\n"))
			 (ret '()))
	(cond
     ((null? lines)
      (string-join (reverse ret) " "))
	 ((#/<h[0-9]>([^<]+)<\/h[0-9]>/ (car lines)) =>
	  (lambda (m) 
        (loop (cdr lines) (cons (m 1) ret))))
     (else
      (loop (cdr lines) ret)))))

(define (check-api-error status headers body)
  (unless (equal? status "200")
    (or (and-let* ([ct (rfc822-header-ref headers "content-type")])
          (match (mime-parse-content-type ct)
                 [(_ "xml" . _)
                  (let1 body-sxml
                      (guard (e (else #f))
                        (call-with-input-string body (cut ssax:xml->sxml <> '())))
                    (error <twitter-api-error>
                           :status status :headers headers :body body
                           :body-sxml body-sxml
                           (or (and body-sxml ((if-car-sxpath '(// error *text*)) body-sxml))
                               body)))]
                 [(_ "json" . _)
                  (let1 body-json
                      (guard (e (else #f))
                        (parse-json-string body))
                    (let ((aref assoc-ref)
                          (vref vector-ref))
                      (error <twitter-api-error>
                             :status status :headers headers :body body
                             :body-json body-json
                             (or (and body-json 
                                      (guard (e (else #f))
                                        (aref (vref (aref body-json "errors") 0) "message")))
                                 body))))]
                 [(_ "html" . _)
                  (error <twitter-api-error>
                         :status status :headers headers :body body
                         (parse-html-message body))]
                 [_ #f]))
        (error <twitter-api-error>
               :status status :headers headers :body body
               body))))

(define (call/oauth->sxml cred method path params . opts)
  (apply call/oauth (lambda (body) 
                      (call-with-input-string body (cut ssax:xml->sxml <> '())))
		 cred method path params opts))

(define (call/oauth parser cred method path params . opts)
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
    (values (parser body) headers))

  (call-with-values call retrieve))

(with-module rfc.mime
  (define (twitter-mime-compose parts
                                :optional (port (current-output-port))
                                :key (boundary (mime-make-boundary)))
    (for-each (cut display <> port) `("--" ,boundary "\r\n"))
    (dolist [p parts]
      (mime-generate-one-part (canonical-part p) port)
      (for-each (cut display <> port) `("\r\n--" ,boundary "--\r\n")))
    boundary))

(define-macro (hack-mime-composing . expr)
  (let ((original (gensym)))
    `(let ((,original #f))
       (with-module rfc.mime
         (set! ,original mime-compose-message)
         (set! mime-compose-message twitter-mime-compose))
       (unwind-protect
        (begin ,@expr)
        (with-module rfc.mime
          (set! mime-compose-message ,original))))))

(define (call/oauth-post-file->sxml cred path params . opts)

  (define (call)
    (let1 auth (oauth-auth-header
                "POST"
                #`"http://api.twitter.com,|path|" '()
                (~ cred'consumer-key) (~ cred'consumer-secret)
                (~ cred'access-token) (~ cred'access-token-secret))
      (hack-mime-composing 
       (apply http-post "api.twitter.com" path
              params
              :Authorization auth opts))))

  (define (retrieve status headers body)
    (check-api-error status headers body)
    (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
            headers))

  (call-with-values call retrieve))
