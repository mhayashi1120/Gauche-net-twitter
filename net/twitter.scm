;;;
;;; Twitter access module (general methods / backward compatibility)
;;;

(define-module net.twitter
  (use net.twitter.core)
  (use net.twitter.friendship :prefix friendship:)
  (use net.twitter.user :prefix user:)
  (use net.twitter.list :prefix list:)
  (use net.twitter.direct-message :prefix dm:)
  (use net.twitter.trends :prefix trends:)
  (use net.twitter.block :prefix block:)
  (use net.twitter.account :prefix account:)
  (use net.twitter.stream :prefix stream:)
  (use net.twitter.favorite :prefix favorite:)
  (use net.twitter.timeline :prefix timeline:)
  (use net.twitter.search :prefix search:)
  (use net.twitter.status :prefix st:)

  (export
   <twitter-cred> <twitter-api-error>

   twitter-home-timeline/json
   twitter-user-timeline/json
   twitter-mentions/json twitter-mentions
   twitter-retweets-of-me/json

   twitter-search/json

   twitter-show/json
   twitter-update/json twitter-update
   twitter-update-with-media/json
   twitter-destroy/json
   twitter-retweet/json
   twitter-retweets/json

   twitter-user-show/json
   twitter-user-lookup/json
   twitter-user-search/json
   twitter-user-suggestions/json
   twitter-user-suggestions/category/json

   twitter-friends/ids/json twitter-friends/ids
   twitter-followers/ids/json twitter-followers/ids
   twitter-friendship-show/json
   twitter-friendship-create/json twitter-friendship-destroy/json
   twitter-friendship-update/json

   twitter-direct-messages/json
   twitter-direct-messages-sent/json
   twitter-direct-message-new/json
   twitter-direct-message-destroy/json

   twitter-lists/json
   ;;TODO
   ;; twitter-lists/ids twitter-lists/slugs
   twitter-list-show/json
   twitter-list-statuses/json
   twitter-list-create/json
   twitter-list-create
   twitter-list-update/json
   twitter-list-destroy/json
   twitter-list-members/json
   twitter-list-member-show/json
   twitter-list-member-create/json
   twitter-list-members-create-all/json
   twitter-list-member-destroy/json
   twitter-list-subscribers/json
   twitter-list-subscriber-create/json
   twitter-list-subscriber-destroy/json
   twitter-list-subscriptions/json
   twitter-list-memberships/json

   twitter-favorites/json
   twitter-favorite-create/json
   twitter-favorite-destroy/json

   twitter-account-verify-credentials/json
   twitter-account-settings/json
   twitter-account-settings-update/json
   twitter-account-update-profile-image/json
   twitter-account-update-profile-background-image/json
   twitter-account-update-profile-colors/json
   twitter-account-update-profile/json
   twitter-account-verify-credentials?

   twitter-blocks-list/json
   twitter-blocks/ids/json
   twitter-block-create/json
   twitter-block-destroy/json
   twitter-block-exists?
   twitter-blocks/ids

   twitter-report-spam/json

   twitter-trends-available/json

   ))
;;TODO
;; twitter-account-rate-limit-status/json

(select-module net.twitter)

(define <twitter-cred> <twitter-cred>)
(define <twitter-api-error> <twitter-api-error>)

;;;
;;; Public API
;;;

;;
;; Timeline methods
;;

(define twitter-home-timeline/json timeline:home-timeline/json)
(define twitter-user-timeline/json timeline:user-timeline/json)
(define twitter-mentions/json timeline:mentions/json)
(define twitter-mentions timeline:mentions)
(define twitter-retweets-of-me/json timeline:retweets-of-me/json)

;;
;; Search API method
;;

(define twitter-search/json search:search/json)
(define twitter-search-tweets/json search:search-tweets/json)

;;
;; Status method
;;

(define twitter-show/json st:status-show/json)
(define twitter-update/json st:status-update/json)
(define twitter-update st:status-update)
(define twitter-update-with-media/json st:status-update-with-media/json)
(define twitter-destroy/json st:status-destroy/json)
(define twitter-retweet/json st:status-retweet/json)
(define twitter-retweets/json st:status-retweets/json)

;;
;; Directmessage methods
;;

(define twitter-direct-messages/json dm:direct-messages/json)
(define twitter-direct-messages-sent/json dm:direct-messages-sent/json)
(define twitter-direct-message-new/json dm:direct-message-new/json)
(define twitter-direct-message-destroy/json dm:direct-message-destroy/json)

;;
;; Friends & Followers
;;

(define twitter-friends/ids/json friendship:friends/ids/json)
(define twitter-friends/ids friendship:friends/ids)
(define twitter-followers/ids/json friendship:followers/ids/json)
(define twitter-followers/ids friendship:followers/ids)

(define twitter-friendship-show/json friendship:friendship-show/json)
(define twitter-friendship-create/json friendship:friendship-create/json)
(define twitter-friendship-destroy/json friendship:friendship-destroy/json)
(define twitter-friendship-update/json friendship:friendship-update/json)

;;
;; List methods
;;

(define twitter-lists/json list:lists/json)
(define twitter-list-show/json list:list-show/json)
(define twitter-list-statuses/json list:list-statuses/json)
(define twitter-list-create/json list:list-create/json)
(define twitter-list-create list:list-create)
(define twitter-list-update/json list:list-update/json)
(define twitter-list-destroy/json list:list-destroy/json)
(define twitter-list-members/json list:list-members/json)
(define twitter-list-member-show/json list:list-member-show/json)
(define twitter-list-member-create/json list:list-member-create/json)
(define twitter-list-members-create-all/json list:list-members-create-all/json)
(define twitter-list-member-destroy/json list:list-member-destroy/json)
(define twitter-list-subscribers/json list:list-subscribers/json)
(define twitter-list-subscriber-create/json list:list-subscriber-create/json)
(define twitter-list-subscriber-destroy/json list:list-subscriber-destroy/json)
(define twitter-list-memberships/json list:list-memberships/json)
(define twitter-list-subscriptions/json list:list-subscriptions/json)


;;
;; Favorites methods
;;

(define twitter-favorites/json favorite:favorites/json)
(define twitter-favorite-create/json favorite:favorite-create/json)
(define twitter-favorite-destroy/json favorite:favorite-destroy/json)

;;
;; Account methods
;;

(define twitter-account-verify-credentials/json account:account-verify-credentials/json)
(define twitter-account-verify-credentials? account:account-verify-credentials?)
(define twitter-account-settings/json account:account-settings/json)
(define twitter-account-settings-update/json account:account-settings-update/json)
(define twitter-account-update-profile-image/json account:account-update-profile-image/json)
(define twitter-account-update-profile-background-image/json account:account-update-profile-background-image/json)
(define twitter-account-update-profile-colors/json account:account-update-profile-colors/json)
(define twitter-account-update-profile/json account:account-update-profile/json)

;;
;; User methods
;;

(define twitter-user-show/json user:user-show/json)
(define twitter-user-lookup/json user:user-lookup/json)
(define twitter-user-search/json user:user-search/json)
(define twitter-user-suggestions/json user:user-suggestions/json)
(define twitter-user-suggestions/category/json user:user-suggestions/category/json)
;;TODO suggestion/members

;;
;; Block methods
;;

(define twitter-blocks-list/json block:blocks-list/json)
(define twitter-blocks/ids/json block:blocks/ids/json)
(define twitter-block-create/json block:block-create/json)
(define twitter-block-destroy/json block:block-destroy/json)
(define twitter-block-exists? block:block-exists?)
(define twitter-blocks/ids block:blocks/ids)

;;
;; Report spam methods
;;

(define twitter-report-spam/json user:report-spam/json)

;;
;; Trend methods
;;

;;TODO remove? or add others?
(define twitter-trends-available/json trends:trends-available/json)

