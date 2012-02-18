(define-module net.twitter.trends
  (use net.twitter.core)
  (use util.list)
  (export
   trends-available/sxml trends-location/sxml))
(select-module net.twitter.trends)

;; CRED can be #f
(define (trends-available/sxml cred :key (lat #f) (long #f))
  (call/oauth->sxml cred 'get #`"/1/trends/available.xml"
                    (make-query-params lat long)))

;; CRED can be #f
(define (trends-location/sxml cred woeid)
  (call/oauth->sxml cred 'get #`"/1/trends/,|woeid|.xml" '()))

