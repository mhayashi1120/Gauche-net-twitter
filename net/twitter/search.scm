(define-module net.twitter.search
  (use rfc.json)
  (use net.twitter.core)
  (use rfc.http)
  (use sxml.ssax)
  (use text.unicode)
  (export
   search/json
   search-tweets/json))
(select-module net.twitter.search)

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

;;TODO not documented..
(define (search/json q :key (lang #f) (locale #f)
                     (rpp #f) (page #f)
                     (since-id #f) (until #f) (geocode #f)
                     (show-user #f) (result-type #f)
                     (max-id #f)
                     :allow-other-keys _keys)
  (let1 params (api-params _keys q lang locale rpp
                           page since-id until geocode
                           max-id show-user result-type)
    (define (call)
      (http-get "search.twitter.com" #`"/search.json?,(compose-query params)"))

    (define (retrieve status headers body)
      (check-search-error status headers body)
      (values (call-with-input-string body (cut parse-json <>))
              headers))

    (call-with-values call retrieve)))

(define (search-tweets/json cred q :key (geocode #f) (lang #f) (locale #f)
                            (result-type #f) (count #f) (until #f)
                            (since-id #f) (max-id #f)
                            (include-entities #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/search/tweets"
                    (api-params _keys q geocode lang locale
                                result-type count until
                                since-id  max-id include-entities)))
