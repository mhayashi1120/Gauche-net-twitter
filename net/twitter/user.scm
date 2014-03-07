(define-module net.twitter.user
  (extend net.twitter.base)
  (use net.twitter.core)
  (export
   show/json
   lookup/json
   search/json
   suggestions/json
   suggestions/category/json
   suggestion/members/json
   profile-banner/json
   report-spam/json))
(select-module net.twitter.user)

;;;
;;; JSON api
;;;

;; cred can be #f.
(define (show/json cred :key (id #f) (user-id #f) (screen-name #f)
                        (include-entities #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/show"
                    (api-params _keys id user-id screen-name
                                include-entities)))

(define (lookup/json cred :key (user-ids '()) (screen-names '())
                          (user-id #f) (screen-name #f)
                          (include-entities #f)
                          :allow-other-keys _keys)
  (set! user-id (or user-id (stringify-param user-ids)))
  (set! screen-name (or screen-name (stringify-param screen-names)))
  (call/oauth->json cred 'post #`"/1.1/users/lookup"
                    (api-params _keys user-id screen-name
                                include-entities)))

(define (search/json cred q :key (page #f) (count #f)
                          (include-entities #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/users/search"
                    (api-params _keys q page count
                                include-entities)))

;; CRED can be #f
(define (suggestions/json cred :key (lang #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/users/suggestions"
                    (api-params _keys lang)))

;; CRED can be #f
(define (suggestions/category/json cred slug :key (lang #f)
                                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/suggestions/,|slug|"
                    (api-params _keys lang)))

(define (suggestion/members/json cred slug . _keys)
  (call/oauth->json cred 'get #`"/1.1/users/suggestions/,|slug|/members"
                    (api-params _keys)))

(define (profile-banner/json cred :key (id #f) (user-id #f)
                                  (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/profile_banner"
                    (api-params _keys id user-id screen-name)))

(define (report-spam/json cred :key (id #f) (user-id #f) (screen-name #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/users/report_spam"
                    (api-params _keys id user-id screen-name)))
