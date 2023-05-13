(define-module net.twitter.search
  (extend net.twitter.base)
  (use rfc.json)
  (use net.twitter.core)
  (use rfc.http)
  (use sxml.ssax)
  (use text.unicode)
  (export
   search-tweets/json
   search-tweets/json$))
(select-module net.twitter.search)

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

;; ##
;; -> <json>
(define (search-tweets/json cred q :key (geocode #f) (lang #f) (locale #f)
                            (result-type #f) (count #f) (until #f)
                            (since-id #f) (max-id #f)
                            (include-entities #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/search/tweets"
                    (api-params _keys q geocode lang locale
                                result-type count until
                                since-id  max-id include-entities)))

;; ## Same arguments as [=search-tweets/json]()
;; -> <generator>
(define (search-tweets/json$ . args)
  (apply stream-generator$
         (^j
          (let1 statuses (vector->list (assoc-ref j "statuses"))
            (values
             (and-let* ([(pair? statuses)]
                        [min-entry (last statuses)]
                        [id (assoc-ref min-entry "id")])
               (list :max-id (- id 1)))
             statuses)))
         search-tweets/json args))
