(define-module net.twitter.timeline
  (use net.twitter.core)
  (use sxml.sxpath)
  (export
   home-timeline/sxml
   user-timeline/sxml
   mentions/sxml
   mentions
   retweeted-to-me/sxml
   retweeted-by-me/sxml
   retweets-of-me/sxml
   retweeted-to-user/sxml
   retweeted-by-user/sxml
   ))
(select-module net.twitter.timeline)

;;
;; Timeline methods
;;
(define (home-timeline/sxml cred :key (since-id #f) (max-id #f)
                            (count #f) (page #f)
                            (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/home_timeline.xml"
                    (query-params since-id max-id count page
                                  trim-user include-entities)))

(define (user-timeline/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                            (since-id #f) (max-id #f)
                            (count #f) (page #f)
                            (trim-user #f) (include-rts #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/user_timeline.xml"
                    (query-params id user-id screen-name since-id max-id count page
                                  trim-user include-rts include-entities)))

(define (mentions/sxml cred :key (since-id #f) (max-id #f)
                       (count #f) (page #f)
                       (trim-user #f) (include-rts #f) (include-entities #f))
  (call/oauth->sxml cred 'get "/1/statuses/mentions.xml"
                    (query-params since-id max-id count page
                                  trim-user include-rts include-entities)))

;; Returns list of (tweet-id text user-screen-name user-id)
(define (mentions cred . args)
  (let ([r (values-ref (apply mentions/sxml cred args) 0)]
        [accessors `(,(if-car-sxpath '(id *text*))
                     ,(if-car-sxpath '(text *text*))
                     ,(if-car-sxpath '(user screen_name *text*))
                     ,(if-car-sxpath '(user id *text*)))])
    (sort-by (map (lambda (s) (map (cut <> s) accessors))
                  ((sxpath '(// status)) r))
             (.$ x->integer car)
             >)))

(define (retweeted-to-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                              (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_to_me.xml"
                    (query-params count page max-id since-id trim-user include-entities)))

(define (retweeted-by-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                              (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_by_me.xml"
                    (query-params count page max-id since-id trim-user include-entities)))

(define (retweets-of-me/sxml cred :key (count #f) (page #f) (max-id #f) (since-id #f)
                             (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweets_of_me.xml"
                    (query-params count page max-id since-id trim-user include-entities)))

(define (retweeted-to-user/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                (count #f) (page #f) (max-id #f) (since-id #f)
                                (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_to_user.xml"
                    (query-params id user-id screen-name
                                  count page max-id since-id trim-user include-entities)))

(define (retweeted-by-user/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                                (count #f) (page #f) (max-id #f) (since-id #f)
                                (trim-user #f) (include-entities #f))
  (call/oauth->sxml cred 'get #`"/1/statuses/retweeted_by_user.xml"
                    (query-params id user-id screen-name
                                  count page max-id since-id trim-user include-entities)))
