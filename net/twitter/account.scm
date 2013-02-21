(define-module net.twitter.account
  (use net.twitter.core)

  (export
   account-verify-credentials/sxml
   account-verify-credentials?
   account-totals/sxml
   account-settings/sxml
   account-settings-update/sxml
   account-rate-limit-status/sxml
   account-update-profile-image/sxml
   account-update-profile-background-image/sxml
   account-update-profile-colors/sxml
   account-update-profile/sxml

   account-verify-credentials/json
   account-totals/json
   account-settings/json
   account-settings-update/json
   account-rate-limit-status/json
   account-update-profile-image/json
   account-update-profile-background-image/json
   account-update-profile-colors/json
   account-update-profile/json
   ))
(select-module net.twitter.account)

;;;
;;; XML api
;;;

(define (account-verify-credentials/sxml
         cred :key (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->sxml cred 'get #`"/1/account/verify_credentials"
                    (api-params _keys include-entities skip-status)))

(define (account-verify-credentials? cred)
  (guard (e ((<twitter-api-error> e) #f))
    (account-verify-credentials/sxml cred)
    #t))

(define (account-totals/sxml cred)
  (call/oauth->sxml cred 'post "/1/account/totals" '()))

(define (account-settings/sxml cred)
  (call/oauth->sxml cred 'get "/1/account/settings" '()))

(define (account-settings-update/sxml cred :key (trend-location-woeid #f)
                                      (sleep-time-enabled #f)
                                      (start-sleep-time #f) (end-sleep-time #f)
                                      (time-zone #f) (lang #f)
                                      :allow-other-keys _keys)
  (call/oauth->sxml cred 'post "/1/account/settings"
                    (api-params _keys trend-location-woeid sleep-time-enabled
                                  start-sleep-time end-sleep-time time-zone lang)))

(define (account-rate-limit-status/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/account/rate_limit_status" '()))

(define (account-update-profile-image/sxml
         cred file :key
         (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth-post->sxml
   cred #`"/1/account/update_profile_image"
   `((image :file ,file))
   (api-params _keys include-entities skip-status)))

(define (account-update-profile-background-image/sxml
         cred file :key (tile #f) (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth-post->sxml
   cred #`"/1/account/update_profile_background_image"
   `((image :file ,file))
   (api-params _keys tile include-entities skip-status)))

;; ex: "000000", "000", "fff", "ffffff"
(define (account-update-profile-colors/sxml
         cred :key
         (profile-background-color #f)
         (profile-link-color #f)
         (profile-sidebar-fill-color #f)
         (profile-sidebar-border-color #f)
         (profile-text-color #f)
         (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->sxml
   cred 'post #`"/1/account/update_profile_colors"
   (api-params _keys profile-background-color profile-text-color
                 profile-link-color
                 profile-sidebar-fill-color
                 profile-sidebar-border-color)))

(define (account-update-profile/sxml
         cred :key (name #f)
         (url #f) (location #f)
         (description #f)
         (include-entities #f) (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->sxml
   cred 'post #`"/1/account/update_profile"
   (api-params _keys name url location description
                 include-entities skip-status)))

;;;
;;; JSON api
;;;

(define (account-verify-credentials/json
         cred :key (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->json cred 'get #`"/1/account/verify_credentials"
                    (api-params _keys include-entities skip-status)))

(define (account-totals/json cred)
  (call/oauth->json cred 'post "/1/account/totals" '()))

(define (account-settings/json cred)
  (call/oauth->json cred 'get "/1/account/settings" '()))

(define (account-settings-update/json cred :key (trend-location-woeid #f)
                                      (sleep-time-enabled #f)
                                      (start-sleep-time #f) (end-sleep-time #f)
                                      (time-zone #f) (lang #f)
                                      :allow-other-keys _keys)
  (call/oauth->json cred 'post "/1/account/settings"
                    (api-params _keys trend-location-woeid sleep-time-enabled
                                  start-sleep-time end-sleep-time time-zone lang)))

(define (account-rate-limit-status/json cred)
  (call/oauth->json cred 'get #`"/1/account/rate_limit_status" '()))

(define (account-update-profile-image/json
         cred file :key
         (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth-post->json
   cred #`"/1/account/update_profile_image"
   `((image :file ,file))
   (api-params _keys include-entities skip-status)))

(define (account-update-profile-background-image/json
         cred file :key (tile #f) (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth-post->json
   cred #`"/1/account/update_profile_background_image"
   `((image :file ,file))
   (api-params _keys tile include-entities skip-status)))

;; ex: "000000", "000", "fff", "ffffff"
(define (account-update-profile-colors/json
         cred :key
         (profile-background-color #f)
         (profile-link-color #f)
         (profile-sidebar-fill-color #f)
         (profile-sidebar-border-color #f)
         (profile-text-color #f)
         (include-entities #f)
         (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1/account/update_profile_colors"
   (api-params _keys profile-background-color profile-text-color
                 profile-link-color
                 profile-sidebar-fill-color
                 profile-sidebar-border-color)))

(define (account-update-profile/json
         cred :key (name #f)
         (url #f) (location #f)
         (description #f)
         (include-entities #f) (skip-status #f)
         :allow-other-keys _keys)
  (call/oauth->json
   cred 'post #`"/1/account/update_profile"
   (api-params _keys name url location description
                 include-entities skip-status)))

