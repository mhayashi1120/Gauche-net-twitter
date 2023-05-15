(define-module net.twitter.cursor.search
  (use net.twitter.search)
  (use net.twitter.cursor)
  (export search-tweets/json$))
(select-module net.twitter.cursor.search)

;; ## Same arguments as [=net.twitter.search:search-tweets/json]()
;; -> <generator>
(define (search-tweets/json$ . args)
  (apply stream-generator$
         (^ [j hdrs]
           (let1 statuses (vector->list (assoc-ref j "statuses"))
             (values
              (and-let* ([(pair? statuses)]
                         [min-entry (last statuses)]
                         [id (assoc-ref min-entry "id")])
                (list :max-id (- id 1)))
              statuses)))
         search-tweets/json args))
