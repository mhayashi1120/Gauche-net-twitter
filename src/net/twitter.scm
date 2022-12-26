;;;
;;; Twitter access module (general methods / backward compatibility)
;;;

(define-module net.twitter
  (use net.twitter.core :prefix core:)
  (use net.twitter.friendship :prefix friendship:)
  (use net.twitter.user :prefix user:)
  (use net.twitter.list :prefix list:)
  (use net.twitter.block :prefix block:)
  (use net.twitter.favorite :prefix favorite:)
  (use net.twitter.timeline :prefix tl:)
  (use net.twitter.search :prefix search:)
  (use net.twitter.status :prefix status:)

  (export
   <twitter-cred> <twitter-api-error>

   twitter-home-timeline/json
   twitter-user-timeline/json
   twitter-mentions/json twitter-mentions
   twitter-retweets-of-me/json

   twitter-search-tweets/json

   twitter-show/json
   twitter-update/json twitter-update
   twitter-update-with-media/json
   twitter-destroy/json
   twitter-retweet/json
   twitter-retweets/json

   twitter-user-show/json
   twitter-user-lookup/json
   twitter-user-search/json

   twitter-friends/json twitter-followers/json
   twitter-friends/ids/json twitter-friends/ids
   twitter-followers/ids/json twitter-followers/ids
   twitter-friendship-show/json
   twitter-friendship-create/json twitter-friendship-destroy/json
   twitter-friendship-update/json

   twitter-lists/json
   twitter-list-show/json
   twitter-list-statuses/json

   twitter-favorites/json
   twitter-favorite-create/json
   twitter-favorite-destroy/json
   ))
(select-module net.twitter)

(define <twitter-cred> core:<twitter-cred>)
(define <twitter-api-error> core:<twitter-api-error>)

;;;
;;; Public API
;;;

;;
;; Timeline methods
;;

(define twitter-home-timeline/json tl:home-timeline/json)
(define twitter-user-timeline/json tl:user-timeline/json)
(define twitter-mentions/json tl:mentions-timeline/json)
(define twitter-mentions tl:mentions)
(define twitter-retweets-of-me/json tl:retweets-of-me/json)

;;
;; Search API method
;;

(define twitter-search-tweets/json search:search-tweets/json)

;;
;; Status method
;;

(define twitter-show/json status:show/json)
(define twitter-update/json status:update/json)
(define twitter-update-with-media/json status:update-with-media/json)
(define twitter-destroy/json status:destroy/json)
(define twitter-retweet/json status:retweet/json)
(define twitter-retweets/json status:retweets/json)

(define (twitter-update . args)
  ($ x->string $ status:update $* identity args))

;;
;; Friends & Followers
;;

(define twitter-friends/ids/json friendship:friends/ids/json)
(define twitter-followers/ids/json friendship:followers/ids/json)

(define twitter-friendship-show/json friendship:show/json)
(define twitter-friendship-create/json friendship:create/json)
(define twitter-friendship-destroy/json friendship:destroy/json)
(define twitter-friendship-update/json friendship:update/json)

(define twitter-followers/json friendship:followers/list/json)
(define twitter-friends/json friendship:friends/list/json)

(define (twitter-friends/ids . args)
  ($ map number->string $ friendship:friends/ids $* identity args))
(define (twitter-followers/ids . args)
  ($ map number->string $ friendship:followers/ids $* identity args))

;;
;; List methods
;;

(define twitter-lists/json list:list/json)
(define twitter-list-show/json list:show/json)
(define twitter-list-statuses/json list:statuses/json)

;;
;; Favorites methods
;;

(define twitter-favorites/json favorite:list/json)
(define twitter-favorite-create/json favorite:create/json)
(define twitter-favorite-destroy/json favorite:destroy/json)

;;
;; User methods
;;

(define twitter-user-show/json user:show/json)
(define twitter-user-lookup/json user:lookup/json)
(define twitter-user-search/json user:search/json)
(define twitter-report-spam/json user:report-spam/json)

