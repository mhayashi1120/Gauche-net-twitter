(define-module net.twitter.search
  (use rfc.json)
  (use net.twitter.core)
  (use rfc.http)
  (use sxml.ssax)
  (use text.unicode)
  (export
   search-tweets/json))
(select-module net.twitter.search)

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

(define (search-tweets/json cred q :key (geocode #f) (lang #f) (locale #f)
                            (result-type #f) (count #f) (until #f)
                            (since-id #f) (max-id #f)
                            (include-entities #f)
                            :allow-other-keys _keys)
  (call/oauth->json cred 'get "/1.1/search/tweets"
                    (api-params _keys q geocode lang locale
                                result-type count until
                                since-id  max-id include-entities)))
