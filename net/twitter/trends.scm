(define-module net.twitter.trends
  (use net.twitter.core)
  (export
   trends-available/json
   trends-closest/json
   trends-place/json
   ))
(select-module net.twitter.trends)

;;;
;;; JSON api
;;;

(define (trends-available/json cred :key (lat #f) (long #f)
                               :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/available"
                    (api-params _keys lat long)))

;;TODO
(define (trends-closest/json cred :key (_dummy #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/closest"
                    (api-params _keys)))

;;TODO
(define (trends-place/json cred :key (_dummy #f)
                             :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/place"
                    (api-params _keys)))

