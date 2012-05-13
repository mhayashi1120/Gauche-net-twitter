(define-module net.twitter.trends
  (use net.twitter.core)
  (export
   trends-available/sxml trends-location/sxml))
(select-module net.twitter.trends)

;; CRED can be #f
(define (trends-available/sxml cred :key (lat #f) (long #f)
                               :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/trends/available.xml"
                    (api-params _keys lat long)))

;; CRED can be #f
(define (trends-location/sxml cred woeid)
  (call/oauth->sxml cred 'get #`"/1/trends/,|woeid|.xml" '()))

