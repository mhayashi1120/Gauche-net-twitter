(define-module net.twitter.geo
  (use net.twitter.core)
  (use srfi-1)
  (export
   geo-search/json geo-similar-places/json
   geo-reverse-geocode/json geo-id/json
   geo-place/json))
(select-module net.twitter.geo)

;;TODO callback is not supported
(define (geo-search/json :key (lat #f) (long #f) (query #f)
                         (ip #f) (granularity #f)
                         (accuracy #f) (max-results #f)
                         (contained-within #f)
                         (attribute:street-address #f)
                         :allow-other-keys _keys)
  (call/oauth #f 'get "/1/geo/search.json"
              (api-params _keys lat long query ip granularity accuracy
                          max-results contained-within
                          attribute:street-address)))

;;TODO test
(define (geo-similar-places/json lat long name :key
								 (contained-within #f)
                                 (attribute:street_address #f)
                                 :allow-other-keys _keys)
  (call/oauth #f 'get "/1/geo/similar_places.json"
              (api-params _keys lat long name contained-within
                          attribute:street_address)))

;;TODO callback is not supported
(define (geo-reverse-geocode/json lat long :key (accuracy #f)
                                  (granularity #f) (max-results #f)
                                  :allow-other-keys _keys)
  (call/oauth #f 'get "/1/geo/reverse_geocode.json"
              (api-params _keys
                          lat long accuracy granularity max-results)))

(define (geo-id/json place-id)
  (call/oauth #f 'get #`"/1/geo/id/,|place-id|.json" '()))

;;TODO test
;;TODO callback is not supported
(define (geo-place/json cred name contained-within token lat long
                        :key (attribute:street-address #f)
                        :allow-other-keys _keys)
  (call/oauth cred 'post "/1/geo/place.json"
              (api-params _keys
                          name contained-within token lat long
                          attribute:street-address)))

