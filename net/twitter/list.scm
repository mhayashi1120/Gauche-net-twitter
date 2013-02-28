(define-module net.twitter.list
  (use net.twitter.core)
  (export
   list/json
   show/json
   statuses/json
   create/json
   update/json
   destroy/json
   members/json
   member-show/json
   member-create/json
   members-create-all/json
   member-destroy/json
   member-destroy-all/json

   subscribers/json
   subscriber-show/json
   subscriber-create/json
   subscriber-destroy/json

   memberships/json
   subscriptions/json

   create
   ))
(select-module net.twitter.list)

;;;
;;; JSON api
;;;

;; require user-id or screen-name
;;TODO rename?
(define (list/json cred :key (id #f) (user-id #f) (screen-name #f)
                   :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/list"
                    (api-params _keys id user-id screen-name)))

;; (or list-id (and slug (or owner-id owner-screen-name)))
(define (show/json cred :key (list-id #f)
                        (slug #f) (owner-id #f) (owner-screen-name #f)
                        :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/show"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (statuses/json cred :key (list-id #f)
                            (slug #f) (owner-id #f) (owner-screen-name #f)
                            (since-id #f) (max-id #f)
                            (count #f) (include-entities #f) (include-rts #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/statuses"
                    (api-params _keys list-id
                                  slug owner-id owner-screen-name
                                  since-id max-id count
                                  include-entities include-rts)))

;; mode is private or public
(define (create/json cred name :key (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/create"
                    (api-params _keys name mode description)))

;; mode is private or public
(define (update/json cred :key (list-id #f)
                          (slug #f) (owner-id #f) (owner-screen-name #f)
                          (name #f) (mode #f) (description #f)
                          :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/update"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  name mode description)))

(define (destroy/json cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (members/json cred :key (list-id #f)
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           (cursor #f) (include-entities #f) (skip-status #f)
                           :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/members"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (member-show/json cred :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (user-id #f) (screen-name #f)
                               (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/members/show"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name
                                  include-entities skip-status)))

(define (member-create/json cred :key (list-id #f)
                                 (slug #f) (owner-id #f) (owner-screen-name #f)
                                 (user-id #f) (screen-name #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/members/create"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (members-create-all/json cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      (user-id #f) (screen-name #f)
                                      (user-ids '()) (screen-names '())
                                      :allow-other-keys _keys)
  (set! user-id (or user-id (stringify-param user-ids)))
  (set! screen-name (or screen-name (stringify-param screen-names)))
  (call/oauth->json cred 'post "/1.1/lists/members/create_all"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                user-id screen-name)))

(define (member-destroy/json cred :key (list-id #f)
                                  (slug #f) (owner-id #f) (owner-screen-name #f)
                                  (user-id #f) (screen-name #f)
                                  :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/members/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (member-destroy-all/json cred :key (list-id #f)
                                      (slug #f) (owner-id #f) (owner-screen-name #f)
                                      (user-id #f) (screen-name #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/members/destroy_all"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  user-id screen-name)))

(define (subscribers/json cred  :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (cursor #f) (include-entities #f) (skip-status #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/subscribers"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (subscriber-show/json cred  :key (list-id #f)
                                   (screen-name #f) (user-id #f) (id #f)
                                   (slug #f) (owner-id #f) (owner-screen-name #f)
                                   (include-entities #f) (skip-status #f)
                                   :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/lists/subscribers/show"
                    (api-params _keys list-id slug owner-id owner-screen-name
                                  cursor include-entities skip-status)))

(define (subscriber-create/json cred :key (list-id #f)
                                     (slug #f) (owner-id #f)
                                     (owner-screen-name #f)
                                     :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/subscribers/create"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (subscriber-destroy/json cred :key (list-id #f)
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/lists/subscribers/destroy"
                    (api-params _keys list-id slug owner-id owner-screen-name)))

(define (memberships/json cred :key (user-id #f) (screen-name #f)
                               (cursor #f) (filter-to-owned-lists #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/lists/memberships"
                    (api-params _keys user-id screen-name
                                  filter-to-owned-lists cursor)))

(define (subscriptions/json cred :key (user-id #f) (screen-name #f)
                                 (cursor #f) (count #f)
                                 :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/lists/subscriptions"
                    (api-params _keys user-id screen-name cursor count)))

;;;
;;; Utilities
;;;

(define (create cred name . opts)
  (assoc-ref
   (values-ref (apply create/json cred name opts) 0)
   "id"))
