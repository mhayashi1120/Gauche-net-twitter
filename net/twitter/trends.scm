(define-module net.twitter.trends
  (use net.twitter.core)
  (export
   trends-available/json trends-location/json))
(select-module net.twitter.trends)

;;;
;;; JSON api
;;;

;; CRED can be #f
(define (trends-available/json cred :key (lat #f) (long #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/available"
                    (api-params _keys lat long)))

;; CRED can be #f
(define (trends-location/json cred woeid)
  (call/oauth->json cred 'get #`"/1.1/trends/,|woeid|" '()))
