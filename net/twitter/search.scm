(define-module net.twitter.search
  (use net.twitter.core)
  (use rfc.http)
  (use sxml.ssax)
  (use text.unicode)
  (use util.list)
  (export
   search/sxml))
(select-module net.twitter.search)

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

(define (search/sxml q :key (lang #f) (locale #f)
                     (rpp #f) (page #f)
                     (since-id #f) (until #f) (geocode #f)
                     (show-user #f) (result-type #f)
                     (max-id #f) (since #f) ; deprecated
                     )
  (let1 params (query-params q lang locale rpp
                             page since-id until geocode
                             show-user result-type)
    (define (call)
      (http-get "search.twitter.com" #`"/search.atom?,(compose-query params)"))

    (define (retrieve status headers body)
      (check-api-error status headers body)
      (values (call-with-input-string body (cut ssax:xml->sxml <> '()))
              headers))

    (call-with-values call retrieve)))

