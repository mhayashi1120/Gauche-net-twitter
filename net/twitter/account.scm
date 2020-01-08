(define-module net.twitter.account
  (extend net.twitter.base)
  (use net.twitter.core)

  (export
   verify-credentials?

   verify-credentials/json
   settings/json
   settings-update/json
   update-profile-image/json
   update-profile-background-image/json
   update-profile-colors/json
   update-profile/json
   update-profile-banner/json
   update-delivery-device/json))
(select-module net.twitter.account)

;;;
;;; JSON api
;;;

(define (verify-credentials/json
         cred :key (include-entities #f)
         (skip-status #f) (include-email #f)
         :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1.1/account/verify_credentials"
                    (api-params _keys include-entities skip-status)))

(define (settings/json cred . _keys)
  (call/oauth->json cred 'get "/1.1/account/settings"
                    (api-params _keys)))

(define (settings-update/json cred :key (trend-location-woeid #f)
                              (sleep-time-enabled #f)
                              (start-sleep-time #f) (end-sleep-time #f)
                              (time-zone #f) (lang #f)
                              (allow-contributor-request #f)
                              :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1.1/account/settings"
                    (api-params _keys trend-location-woeid sleep-time-enabled
                                start-sleep-time end-sleep-time time-zone lang
                                allow-contributor-request)))

(define (update-profile-image/json
         cred image :key
         (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth-post->json
   cred #`"/1.1/account/update_profile_image"
   `((image :file ,image))
   (api-params _keys include-entities skip-status)))

(define (update-profile-background-image/json
         cred image :key (tile #f) (include-entities #f)
         (skip-status #f) (media-id #f)
         :allow-other-keys _keys)
  (call/oauth-post->json
   cred #`"/1.1/account/update_profile_background_image"
   `((image :file ,image))
   (api-params _keys tile include-entities skip-status use)))

;; ex: "000000", "000", "fff", "ffffff"
(define (update-profile-colors/json
         cred :key (profile-background-color #f)
         (profile-link-color #f) (profile-sidebar-fill-color #f)
         (profile-sidebar-border-color #f) (profile-text-color #f)
         (include-entities #f) (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1.1/account/update_profile_colors"
   (api-params _keys profile-background-color profile-text-color
               profile-link-color
               profile-sidebar-fill-color
               profile-sidebar-border-color)))

(define (update-profile/json
         cred :key (name #f)
         (url #f) (location #f)
         (description #f)
         (include-entities #f) (skip-status #f)
         (profile-link-color #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1.1/account/update_profile"
   (api-params _keys name url location description
               include-entities skip-status)))

;;TODO test
(define (update-profile-banner/json
         cred :key (height #f) (width #f) (banner #f)
         (offset-top #f) (offset-left #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1.1/account/update_profile_banner"
   (api-params _keys height width banner offset-top offset-left)))

;;TODO test
(define (remove-profile-banner/json
         cred :key (name #f)
         (url #f) (location #f)
         (description #f)
         (include-entities #f) (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1.1/account/remove_profile_banner"
   (api-params _keys name url location description
               include-entities skip-status)))

;;TODO test
(define (update-delivery-device/json
         cred :key (device #f) (include-entities #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1.1/account/update_delivery_device"
   (api-params _keys device include-entities)))

;;;
;;; Utilities
;;;

(define (verify-credentials? cred)
  (guard (e [(and (<twitter-api-error> e)
                  (equal? (condition-ref e 'status) "401"))
             #f])
    (verify-credentials/json cred)
    #t))

