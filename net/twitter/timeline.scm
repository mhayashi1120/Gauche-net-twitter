(define-module net.twitter.timeline
  (use net.twitter.core)
  (export
   mentions

   home-timeline/json
   user-timeline/json
   mentions-timeline/json
   retweets-of-me/json
   ))
(select-module net.twitter.timeline)

;;;
;;; JSON api
;;;

;;
;; Timeline methods
;;
(define (home-timeline/json cred :key (since-id #f) (max-id #f)
                            (count #f) (trim-user #f) (include-entities #f)
                            (exclude-replies #f) (contributor-details #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/statuses/home_timeline"
                    (api-params _keys since-id max-id count
                                trim-user include-entities
                                exclude-replies contributor-details)))

(define (user-timeline/json cred :key (id #f) (user-id #f) (screen-name #f)
                            (since-id #f) (max-id #f)
                            (count #f)
                            (trim-user #f) (include-rts #f)
                            (exclude-replies #f) (contributor-details #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/statuses/user_timeline"
                    (api-params _keys id user-id screen-name since-id max-id count
                                trim-user include-rts exclude-replies
                                contributor-details)))

(define (mentions-timeline/json cred :key (since-id #f) (max-id #f)
                       (count #f) (contributor-details #f)
                       (trim-user #f) (include-entities #f)
                       :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/statuses/mentions_timeline"
                    (api-params _keys since-id max-id count contributor-details
                                trim-user include-entities)))

(define (retweets-of-me/json cred :key (count #f) (max-id #f) (since-id #f)
                             (trim-user #f) (include-entities #f)
                             (include-user-entities #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/statuses/retweets_of_me"
                    (api-params _keys count max-id since-id trim-user
                                include-entities include-user-entities)))

;;;
;;; Utilities
;;;

;; Returns list of (tweet-id text user-screen-name user-id)
(define (mentions cred . args)
  (let* ([r (values-ref (apply mentions-timeline/json cred args) 0)]
         [accessors `((id_str)
                      (text)
                      (user screen_name)
                      (user id))]
         [data (map (^s
                     `(
                       ,(assoc-ref s "id")
                       ,(assoc-ref s "text")
                       ,(assoc-ref "screen_name" (assoc-ref s "user"))
                       ,(assoc-ref "id" (assoc-ref s "id"(assoc-ref s "user")))
                       )
                     ) r)])
    (sort-by data car >)))
