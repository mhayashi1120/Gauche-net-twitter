(define-module net.twitter.list
  (use net.twitter.core)
  (use util.list)
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
   list-subscriber-show/sxml
   list-subscriber-create/sxml
   list-subscriber-destroy/sxml
   list-subscribers/ids
   list-memberships/sxml
   list-memberships/ids
   list-subscriptions/sxml
   list-subscriptions/ids
   ))
(select-module net.twitter.list)

;; require user-id or screen-name
(define (lists/sxml cred :key (id #f) (user-id #f) (screen-name #f)
                    (cursor #f))
  (call/oauth->sxml cred 'get "/1/lists.xml"
                    (query-params id user-id screen-name cursor)))

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
                        (slug #f) (owner-id #f) (owner-screen-name #f))
  (call/oauth->sxml cred 'get "/1/lists/show.xml"
                    (query-params list-id slug owner-id owner-screen-name)))

(define (list-statuses/sxml cred :key (list-id #f)
                            (slug #f) (owner-id #f) (owner-screen-name #f)
                            (since-id #f) (max-id #f)
                            (per-page #f) (page #f)
                            (include-entities #f) (include-rts #f))
  (call/oauth->sxml cred 'get "/1/lists/statuses.xml"
                    (query-params list-id 
                                  slug owner-id owner-screen-name
                                  since-id max-id per-page page
                                  include-entities include-rts)))

;; mode is private or public
(define (list-create/sxml cred name :key (mode #f) (description #f))
  (call/oauth->sxml cred 'post "/1/lists/create.xml"
                    (query-params name mode description)))

;; Returns list id when succeeded
(define (list-create cred name . opts)
  ((if-car-sxpath '(list id *text*))
   (values-ref (apply list-create/sxml cred name opts) 0)))

;; mode is private or public
(define (list-update/sxml cred :key (list-id #f)
                          (slug #f) (owner-id #f) (owner-screen-name #f)
                          (name #f) (mode #f) (description #f))
  (call/oauth->sxml cred 'post "/1/lists/update.xml"
                    (query-params list-id slug owner-id owner-screen-name
                                  name mode description)))

(define (list-destroy/sxml cred :key (list-id #f) 
                           (slug #f) (owner-id #f) (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/destroy.xml"
                    (query-params list-id slug owner-id owner-screen-name)))

(define (list-members/sxml cred :key (list-id #f) 
                           (slug #f) (owner-id #f) (owner-screen-name #f)
                           (cursor #f) (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/members.xml"
                    (query-params list-id slug owner-id owner-screen-name 
                                  cursor include-entities skip-status)))

(define (list-member-show/sxml cred :key (list-id #f)
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (user-id #f) (screen-name #f)
                               (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/members/show.xml" 
                    (query-params list-id slug owner-id owner-screen-name 
                                  user-id screen-name
                                  include-entities skip-status)))

(define (list-member-create/sxml cred :key (list-id #f)
                                 (slug #f) (owner-id #f) (owner-screen-name #f)
                                 (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/members/create.xml"
                    (query-params list-id slug owner-id owner-screen-name 
                                  user-id screen-name)))

(define (list-members-create-all/sxml cred :key (list-id #f) 
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f)
                                      (user-ids #f) (screen-names #f))
  (let ((user-id (and (pair? user-ids) (string-join user-ids ",")))
        (screen-name (and (pair? screen-names) (string-join screen-names ","))))
    (call/oauth->sxml cred 'post "/1/lists/members/create_all.xml"
                      (query-params list-id slug owner-id owner-screen-name 
                                    user-id screen-name))))

(define (list-member-destroy/sxml cred :key (list-id #f)
                                  (slug #f) (owner-id #f) (owner-screen-name #f)
                                  (user-id #f) (screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/members/destroy.xml"
                    (query-params list-id slug owner-id owner-screen-name 
                                  user-id screen-name)))

;; args are passed to twitter-list-members/sxml
(define (list-members/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         list-members/sxml args))

(define (list-subscribers/sxml cred  :key (list-id #f) 
                               (slug #f) (owner-id #f) (owner-screen-name #f)
                               (cursor #f) (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/lists/subscribers.xml"
                    (query-params list-id slug owner-id owner-screen-name 
                                  cursor include-entities skip-status)))

(define (list-subscriber-show/sxml cred :key (list-id #f) 
                                   (slug #f) (owner-id #f) (owner-screen-name #f)
                                   (user-id #f) (screen-name #f)
                                   (include-entities #f) (skip-status #f))
  (call/oauth->sxml cred 'get "/1/subscribers/show.xml" 
                    (query-params list-id slug owner-id owner-screen-name 
                                  user-id screen-name)))

(define (list-subscriber-create/sxml cred :key (list-id #f) 
                                     (slug #f) (owner-id #f)
                                     (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/subscribers/create.xml"
                    (query-params list-id slug owner-id owner-screen-name)))

(define (list-subscriber-destroy/sxml cred :key (list-id #f) 
                                      (slug #f) (owner-id #f)
                                      (owner-screen-name #f))
  (call/oauth->sxml cred 'post "/1/lists/subscribers/destroy.xml"
                    (query-params list-id slug owner-id owner-screen-name)))

;; args are passed to list-subscribers/sxml
(define (list-subscribers/ids . args)
  (apply retrieve-stream (sxpath '(// user id *text*))
         list-subscribers/sxml args))

(define (list-memberships/sxml cred :key (user-id #f) (screen-name #f) 
                               (cursor #f) (filter-to-owned-lists #f))
  (call/oauth->sxml cred 'get #`"/1/lists/memberships.xml"
                    (query-params user-id screen-name
                                  filter-to-owned-lists cursor)))

;; args are passed to list-memberships/sxml 
(define (list-memberships/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*)) 
         list-memberships/sxml 
         cred args))

(define (list-subscriptions/sxml cred :key (user-id #f) (screen-name #f)
                                 (cursor #f))
  (call/oauth->sxml cred 'get #`"/1/lists/subscriptions.xml"
                    (query-params user-id screen-name cursor)))

;; args are passed to list-subscriptions/sxml
(define (list-subscriptions/ids cred . args)
  (apply retrieve-stream (sxpath '(// list id *text*)) 
         list-subscriptions/sxml
         cred args))
