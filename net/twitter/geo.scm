(define-module net.twitter.geo
  (use net.twitter.core)
  (use srfi-1)
  (export
   search/json similar-places/json
   reverse-geocode/json id/json
   place/json))
(select-module net.twitter.geo)

;;;
;;; JSON api
;;;

(define (search/json :key (lat #f) (long #f) (query #f)
                     (ip #f) (granularity #f)
                     (accuracy #f) (max-results #f)
                     (contained-within #f)
                     (attribute:street-address #f)
                     :allow-other-keys _keys)
  (call/oauth #f 'get "/1.1/geo/search"
              (api-params _keys lat long query ip granularity accuracy
                          max-results contained-within
                          attribute:street-address)))

;;TODO test
(define (similar-places/json lat long name :key
                             (contained-within #f)
                             (attribute:street-address #f)
                             :allow-other-keys _keys)
  (call/oauth #f 'get "/1.1/geo/similar_places"
              (api-params _keys lat long name contained-within
                          attribute:street-address)))

(define (reverse-geocode/json lat long :key (accuracy #f)
                              (granularity #f) (max-results #f)
                              :allow-other-keys _keys)
  (call/oauth #f 'get "/1.1/geo/reverse_geocode"
              (api-params _keys
                          lat long accuracy granularity max-results)))

(define (id/json place-id . _keys)
  (call/oauth #f 'get #`"/1.1/geo/id/,|place-id|"
              (api-params _keys)))

;;TODO test
(define (place/json cred name contained-within token lat long
                    :key (attribute:street-address #f)
                    :allow-other-keys _keys)
  (call/oauth cred 'post "/1.1/geo/place"
              (api-params _keys
                          name contained-within token lat long
                          attribute:street-address)))

