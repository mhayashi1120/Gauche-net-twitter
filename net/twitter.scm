;;;
;;; Twitter access module (general methods / backward compatibility)
;;;

(define-module net.twitter
  (use net.twitter.core)
  (use net.twitter.friendship :prefix friendship:)
  (use net.twitter.notification :prefix notification:)
  (use net.twitter.user :prefix user:)
  (use net.twitter.list :prefix list:)
  (use net.twitter.direct-message :prefix dm:)
  (use net.twitter.trends :prefix trends:)
  (use net.twitter.spam :prefix spam:)
  (use net.twitter.block :prefix block:)
  (use net.twitter.account :prefix account:)
  (use net.twitter.stream :prefix stream:)
  (use net.twitter.favorite :prefix favorite:)
  (use net.twitter.legal :prefix legal:)
  (use net.twitter.timeline :prefix timeline:)
  (use net.twitter.search :prefix search:)
  (use net.twitter.tweet :prefix tweet:)

  (export
   <twitter-cred> <twitter-api-error>

   twitter-home-timeline/sxml
   twitter-user-timeline/sxml
   twitter-mentions/sxml twitter-mentions
   twitter-retweeted-to-me/sxml
   twitter-retweeted-by-me/sxml
   twitter-retweets-of-me/sxml
   twitter-retweeted-to-user/sxml
   twitter-retweeted-by-user/sxml

   twitter-search/sxml

   twitter-show/sxml
   twitter-update/sxml twitter-update
   twitter-update-with-media/sxml
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
   twitter-friendship-show/sxml
   twitter-friendship-exists/sxml twitter-friendship-exists?
   twitter-friendship-create/sxml twitter-friendship-destroy/sxml
   twitter-friendship-update/sxml

   twitter-direct-messages/sxml
   twitter-direct-messages-sent/sxml
   twitter-direct-message-new/sxml
   twitter-direct-message-destroy/sxml

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

   twitter-trends-available/sxml twitter-trends-location/sxml

   twitter-legal-tos/sxml twitter-legal-privacy/sxml
   ))
(select-module net.twitter)

(define <twitter-cred> <twitter-cred>)
(define <twitter-api-error> <twitter-api-error>)

;;;
;;; Public API
;;;

;;
;; Timeline methods
;;

(define twitter-home-timeline/sxml timeline:home-timeline/sxml)
(define twitter-user-timeline/sxml timeline:user-timeline/sxml)
(define twitter-mentions/sxml timeline:mentions/sxml)
(define twitter-mentions timeline:mentions)
(define twitter-retweeted-to-me/sxml timeline:retweeted-to-me/sxml)
(define twitter-retweeted-by-me/sxml timeline:retweeted-by-me/sxml)
(define twitter-retweets-of-me/sxml timeline:retweets-of-me/sxml)
(define twitter-retweeted-to-user/sxml timeline:retweeted-to-user/sxml)
(define twitter-retweeted-by-user/sxml timeline:retweeted-by-user/sxml)

;;
;; Search API method
;;

(define twitter-search/sxml search:search/sxml)

;;
;; Status method
;;

(define twitter-show/sxml tweet:show/sxml)
(define twitter-update/sxml tweet:update/sxml)
(define twitter-update tweet:update)
(define twitter-update-with-media/sxml tweet:update-with-media/sxml)
(define twitter-destroy/sxml tweet:destroy/sxml)
(define twitter-retweet/sxml tweet:retweet/sxml)
(define twitter-retweets/sxml tweet:retweets/sxml)
(define twitter-retweeted-by/sxml tweet:retweeted-by/sxml)
(define twitter-retweeted-by-ids/sxml tweet:retweeted-by-ids/sxml)

;;
;; Directmessage methods
;;

(define twitter-direct-messages/sxml dm:direct-messages/sxml)
(define twitter-direct-messages-sent/sxml dm:direct-messages-sent/sxml)
(define twitter-direct-message-new/sxml dm:direct-message-new/sxml)
(define twitter-direct-message-destroy/sxml dm:direct-message-destroy/sxml)

;;
;; Friends & Followers
;;

(define twitter-friends/ids/sxml friendship:friends/ids/sxml)
(define twitter-friends/ids friendship:friends/ids)
(define twitter-followers/ids/sxml friendship:followers/ids/sxml)
(define twitter-followers/ids friendship:followers/ids)

(define twitter-friendship-show/sxml friendship:friendship-show/sxml)
(define twitter-friendship-exists/sxml friendship:friendship-exists/sxml)
(define twitter-friendship-exists? friendship:friendship-exists?)
(define twitter-friendship-create/sxml friendship:friendship-create/sxml)
(define twitter-friendship-destroy/sxml friendship:friendship-destroy/sxml)
(define twitter-friendship-update/sxml friendship:friendship-update/sxml)

;;
;; List methods
;;

(define twitter-lists/sxml list:lists/sxml)
(define twitter-lists/ids list:lists/ids)
(define twitter-lists/slugs list:lists/slugs)
(define twitter-list-show/sxml list:list-show/sxml)
(define twitter-list-statuses/sxml list:list-statuses/sxml)
(define twitter-list-create/sxml list:list-create/sxml)
(define twitter-list-create list:list-create)
(define twitter-list-update/sxml list:list-update/sxml)
(define twitter-list-destroy/sxml list:list-destroy/sxml)
(define twitter-list-members/sxml list:list-members/sxml)
(define twitter-list-member-show/sxml list:list-member-show/sxml)
(define twitter-list-member-create/sxml list:list-member-create/sxml)
(define twitter-list-members-create-all/sxml list:list-members-create-all/sxml)
(define twitter-list-member-destroy/sxml list:list-member-destroy/sxml)
(define twitter-list-members/ids list:list-members/ids)
(define twitter-list-subscribers/sxml list:list-subscribers/sxml)
(define twitter-list-subscriber-create/sxml list:list-subscriber-create/sxml)
(define twitter-list-subscriber-destroy/sxml list:list-subscriber-destroy/sxml)
(define twitter-list-subscribers/ids list:list-subscribers/ids)
(define twitter-list-memberships/sxml list:list-memberships/sxml)
(define twitter-list-memberships/ids list:list-memberships/ids)
(define twitter-list-subscriptions/sxml list:list-subscriptions/sxml)
(define twitter-list-subscriptions/ids list:list-subscriptions/ids)


;;
;; Favorites methods
;;

(define twitter-favorites/sxml favorite:favorites/sxml)
(define twitter-favorite-create/sxml favorite:favorite-create/sxml)
(define twitter-favorite-destroy/sxml favorite:favorite-destroy/sxml)

;;
;; Account methods
;;

(define twitter-account-verify-credentials/sxml account:account-verify-credentials/sxml)
(define twitter-account-verify-credentials? account:account-verify-credentials?)
(define twitter-account-totals/sxml account:account-totals/sxml)
(define twitter-account-settings/sxml account:account-settings/sxml)
(define twitter-account-settings-update/sxml account:account-settings-update/sxml)
(define twitter-account-rate-limit-status/sxml account:account-rate-limit-status/sxml)
(define twitter-account-update-profile-image/sxml account:account-update-profile-image/sxml)
(define twitter-account-update-profile-background-image/sxml account:account-update-profile-background-image/sxml)
(define twitter-account-update-profile-colors/sxml account:account-update-profile-colors/sxml)
(define twitter-account-update-profile/sxml account:account-update-profile/sxml)

;;
;; User methods
;;

(define twitter-user-show/sxml user:user-show/sxml)
(define twitter-user-lookup/sxml user:user-lookup/sxml)
(define twitter-user-search/sxml user:user-search/sxml)
(define twitter-user-suggestions/sxml user:user-suggestions/sxml)
(define twitter-user-suggestions/category/sxml user:user-suggestions/category/sxml)


;;
;; Notification methods
;;

(define twitter-notifications-follow/sxml notification:notifications-follow/sxml)
(define twitter-notifications-leave/sxml notification:notifications-leave/sxml)

;;
;; Block methods
;;

(define twitter-blocks/sxml block:blocks/sxml)
(define twitter-blocks/ids/sxml block:blocks/ids/sxml)
(define twitter-block-create/sxml block:block-create/sxml)
(define twitter-block-destroy/sxml block:block-destroy/sxml)
(define twitter-block-exists/sxml block:block-exists/sxml)
(define twitter-block-exists? block:block-exists?)
(define twitter-blocks/ids block:blocks/ids)

;;
;; Report spam methods
;;

(define twitter-report-spam/sxml spam:report-spam/sxml)

;;
;; Trend methods
;;

(define twitter-trends-available/sxml trends:trends-available/sxml)
(define twitter-trends-location/sxml trends:trends-location/sxml)

;;
;; Legal methods
;;

(define twitter-legal-tos/sxml legal:legal-tos/sxml)
(define twitter-legal-privacy/sxml legal:legal-privacy/sxml)

