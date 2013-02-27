(define-module net.twitter.user
  (use net.twitter.core)
  (export
   user-show/json
   user-lookup/json
   user-search/json
   user-suggestions/json
   user-suggestions/category/json
   user-suggestion/members/json

   report-spam/json))
(select-module net.twitter.user)

;;;
;;; JSON api
;;;

;; cred can be #f.
(define (user-show/json cred :key (id #f) (user-id #f) (screen-name #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/show"
                    (api-params _keys id user-id screen-name)))

(define (user-lookup/json cred :key (user-ids '()) (screen-names '())
                          (include-entities #f) (skip-status #f)
                          :allow-other-keys _keys)
  (let ((user-id (and (pair? user-ids) (string-join (map x->string user-ids) ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->json cred 'post #`"/1.1/users/lookup"
                      (api-params _keys user-id screen-name
                                    include-entities skip-status))))

(define (user-search/json cred q :key (per-page #f) (page #f)
                          (include-entities #f) (skip-status #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/users/search"
                    (api-params _keys q per-page page
                                  include-entities skip-status)))

;; CRED can be #f
(define (user-suggestions/json cred :key (lang #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/users/suggestions"
                    (api-params _keys lang)))

;; CRED can be #f
(define (user-suggestions/category/json cred slug :key (lang #f)
                                        :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/suggestions/,|slug|"
                    (api-params _keys lang)))

(define (user-suggestion/members/json cred slug :key (_dummy #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/users/suggestions/,|slug|/members"
                    (api-params _keys)))

(define (report-spam/json cred :key (id #f) (user-id #f) (screen-name #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post #`"/1.1/users/report_spam"
                    (api-params _keys id user-id screen-name)))
