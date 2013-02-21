(define-module net.twitter.list
  (use net.twitter.core)
  (use sxml.sxpath)
  (export
   lists/sxml
   lists/ids
   lists/slugs
   list-show/sxml
   list-statuses/sxml
   list-create/sxml
   list-create
   list-update/sxml
   list-destroy/sxml
   list-members/sxml
   list-member-show/sxml
   list-member-create/sxml
   list-members-create-all/sxml
   list-member-destroy/sxml
   list-members/ids
   list-subscribers/sxml
   list-subscriber-create/sxml
   list-subscriber-destroy/sxml
   list-subscribers/ids
   list-memberships/sxml
   list-memberships/ids
   list-subscriptions/sxml
   list-subscriptions/ids

   lists/json
   list-show/json
   list-statuses/json
   list-create/json
   list-update/json
   list-destroy/json
   list-members/json
   list-member-show/json
   list-member-create/json
   list-members-create-all/json
   list-member-destroy/json
   list-subscribers/json
   list-subscriber-create/json
   list-subscriber-destroy/json
   list-memberships/json
   list-subscriptions/json
   ))
(select-module net.twitter.list)

;;;
;;; XML api
;;;

;; require user-id or screen-name
(define (lists/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                    (cursor #f)
                    :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists"
                    (api-params _keys id user-id screen-name cursor)))

;; args are passed to lists/sxml
(define (lists/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*))
         lists/sxml cred args))

;; args are passed to lists/sxml
(define (lists/slugs cred . args)
  (apply retrieve-stream (sxpath '(// list name *text*))
         lists/sxml cred args))

;; (or list-id (and slug (or owner-id owner-screen-name)))
(define (list-show/sxml cred :key (list-id #f)
                        (slug #f) (owner-id #f) (owner-screen-name #f)
                        :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists/show"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-statuses/sxml cred :key (list-id #f)
                            (slug #f) (owner-id #f) (owner-screen-name #f)
                            (since-id #f) (max-id #f)
                            (per-page #f) (page #f)
                            (include-entities #f) (include-rts #f)
                            :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists/statuses"
                    (api-params _keys list-id
                                  slug owner-id owner-screen-name
                                  since-id max-id per-page page
                                  include-entities include-rts)))

;; mode is private or public
(define (list-create/sxml cred name :key (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/create"
                    (api-params _keys name mode description)))

;; Returns list id when succeeded
(define (list-create cred name . opts)
  ((if-car-sxpath '(list id *text*))
   (values-ref (apply list-create/sxml cred name opts) 0)))

;; mode is private or public
(define (list-update/sxml cred :key (list-id #f)
                          (slug #f) (owner-id #f) (owner-screen-name #f)
                          (name #f) (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/update"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  name mode description)))

(define (list-destroy/sxml cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-members/sxml cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           (cursor #f) (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists/members"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (list-member-show/sxml cred :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (user-id #f) (screen-name #f)
                               (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists/members/show"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name
                                  include-entities skip-status)))

(define (list-member-create/sxml cred :key (list-id #f)
                                 (slug #f) (owner-id #f) (owner-screen-name #f)
                                 (user-id #f) (screen-name #f)
                                 :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/members/create"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (list-members-create-all/sxml cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      (user-ids #f) (screen-names #f)
                                      :allow-other-keys _keys)
  (let ((user-id (and (pair? user-ids) (string-join (map x->string user-ids) ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->sxml cred 'post "/1/lists/members/create_all"
                      (api-params _keys list-id slug owner-id owner-screen-name
                                    user-id screen-name))))

(define (list-member-destroy/sxml cred :key (list-id #f)
                                  (slug #f) (owner-id #f) (owner-screen-name #f)
                                  (user-id #f) (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/members/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

;; args are passed to twitter-list-members/sxml
(define (list-members/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         list-members/sxml args))

(define (list-subscribers/sxml cred  :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (cursor #f) (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get "/1/lists/subscribers"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (list-subscriber-create/sxml cred :key (list-id #f)
                                     (slug #f) (owner-id #f)
                                     (owner-screen-name #f)
                                     :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/subscribers/create"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-subscriber-destroy/sxml cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/lists/subscribers/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

;; args are passed to list-subscribers/sxml
(define (list-subscribers/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         list-subscribers/sxml args))

(define (list-memberships/sxml cred :key (user-id #f) (screen-name #f)
                               (cursor #f) (filter-to-owned-lists #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/lists/memberships"
                    (api-params _keys user-id screen-name
                                  filter-to-owned-lists cursor)))

;; args are passed to list-memberships/sxml
(define (list-memberships/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*))
         list-memberships/sxml
         cred args))

(define (list-subscriptions/sxml cred :key (user-id #f) (screen-name #f)
                                 (cursor #f)
                                 :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/lists/subscriptions"
                    (api-params _keys user-id screen-name cursor)))

;; args are passed to list-subscriptions/sxml
(define (list-subscriptions/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*))
         list-subscriptions/sxml
         cred args))

;;;
;;; JSON api
;;;

;; require user-id or screen-name
(define (lists/json cred :key (id #f) (user-id #f) (screen-name #f)
                    (cursor #f)
                    :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists"
                    (api-params _keys id user-id screen-name cursor)))

;; (or list-id (and slug (or owner-id owner-screen-name)))
(define (list-show/json cred :key (list-id #f)
                        (slug #f) (owner-id #f) (owner-screen-name #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists/show"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-statuses/json cred :key (list-id #f)
                            (slug #f) (owner-id #f) (owner-screen-name #f)
                            (since-id #f) (max-id #f)
                            (per-page #f) (page #f)
                            (include-entities #f) (include-rts #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists/statuses"
                    (api-params _keys list-id
                                  slug owner-id owner-screen-name
                                  since-id max-id per-page page
                                  include-entities include-rts)))

;; mode is private or public
(define (list-create/json cred name :key (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/create"
                    (api-params _keys name mode description)))

;; mode is private or public
(define (list-update/json cred :key (list-id #f)
                          (slug #f) (owner-id #f) (owner-screen-name #f)
                          (name #f) (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/update"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  name mode description)))

(define (list-destroy/json cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-members/json cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           (cursor #f) (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists/members"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (list-member-show/json cred :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (user-id #f) (screen-name #f)
                               (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists/members/show"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name
                                  include-entities skip-status)))

(define (list-member-create/json cred :key (list-id #f)
                                 (slug #f) (owner-id #f) (owner-screen-name #f)
                                 (user-id #f) (screen-name #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/members/create"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (list-members-create-all/json cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      (user-ids #f) (screen-names #f)
                                      :allow-other-keys _keys)
  (let ((user-id (and (pair? user-ids) (string-join (map x->string user-ids) ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->json cred 'post "/1/lists/members/create_all"
                      (api-params _keys list-id slug owner-id owner-screen-name
                                    user-id screen-name))))

(define (list-member-destroy/json cred :key (list-id #f)
                                  (slug #f) (owner-id #f) (owner-screen-name #f)
                                  (user-id #f) (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/members/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (list-subscribers/json cred  :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (cursor #f) (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1/lists/subscribers"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (list-subscriber-create/json cred :key (list-id #f)
                                     (slug #f) (owner-id #f)
                                     (owner-screen-name #f)
                                     :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/subscribers/create"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-subscriber-destroy/json cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/lists/subscribers/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (list-memberships/json cred :key (user-id #f) (screen-name #f)
                               (cursor #f) (filter-to-owned-lists #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/lists/memberships"
                    (api-params _keys user-id screen-name
                                  filter-to-owned-lists cursor)))

(define (list-subscriptions/json cred :key (user-id #f) (screen-name #f)
                                 (cursor #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/lists/subscriptions"
                    (api-params _keys user-id screen-name cursor)))

