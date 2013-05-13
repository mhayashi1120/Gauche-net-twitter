(define-module net.twitter.trends
  (use net.twitter.core)
  (export
   available/json
   closest/json
   place/json
   ))
(select-module net.twitter.trends)

;;;
;;; JSON api
;;;

(define (available/json cred . _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/available"
                    (api-params _keys)))

;;TODO test
(define (closest/json cred :key (lat #f) (long #f)
                      :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/closest"
                    (api-params _keys lat long)))

;;TODO test
(define (place/json cred :key (exclude #f) (id #f)
                    :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/trends/place"
                    (api-params _keys exclude id)))

