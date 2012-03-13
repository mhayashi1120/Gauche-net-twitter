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
   ))
(select-module net.twitter.account)

(define (account-verify-credentials/sxml
         cred :key (include-entities #f)
         (skip-status #f))
  (call/oauth->sxml cred 'get #`"/1/account/verify_credentials.xml" 
                    (query-params include-entities skip-status)))

(define (account-verify-credentials? cred)
  (guard (e ((<twitter-api-error> e) #f))
    (account-verify-credentials/sxml cred)
    #t))

(define (account-totals/sxml cred)
  (call/oauth->sxml cred 'post "/1/account/totals.xml" '()))

(define (account-settings/sxml cred)
  (call/oauth->sxml cred 'get "/1/account/settings.xml" '()))

(define (account-settings-update/sxml cred :key (trend-location-woeid #f)
                                      (sleep-time-enabled #f)
                                      (start-sleep-time #f) (end-sleep-time #f)
                                      (time-zone #f) (lang #f))
  (call/oauth->sxml cred 'post "/1/account/settings.xml" 
                    (query-params trend-location-woeid sleep-time-enabled
                                  start-sleep-time end-sleep-time time-zone lang)))

(define (account-rate-limit-status/sxml cred)
  (call/oauth->sxml cred 'get #`"/1/account/rate_limit_status.xml" '()))

(define (account-update-profile-image/sxml 
         cred file :key
         (include-entities #f)
         (skip-status #f))
  (call/oauth-post->sxml
   cred #`"/1/account/update_profile_image.xml"
   `((image :file ,file))
   (query-params include-entities skip-status)))

(define (account-update-profile-background-image/sxml 
         cred file :key
         (tile #f)
         (include-entities #f)
         (skip-status #f)
         (use #f))
  (call/oauth-post->sxml
   cred #`"/1/account/update_profile_background_image.xml"
   `((image :file ,file))
   (query-params tile include-entities skip-status)))

;; ex: "000000", "000", "fff", "ffffff"
(define (account-update-profile-colors/sxml
         cred :key 
         (profile-background-color #f)
         (profile-link-color #f)
         (profile-sidebar-fill-color #f)
         (profile-sidebar-border-color #f)
         (profile-text-color #f)
         (include-entities #f)
         (skip-status #f))
  (call/oauth->sxml
   cred 'post #`"/1/account/update_profile_colors.xml"
   (query-params profile-background-color profile-text-color
                 profile-link-color
                 profile-sidebar-fill-color
                 profile-sidebar-border-color)))

(define (account-update-profile/sxml
         cred :key (name #f)
         (url #f) (location #f)
         (description #f)
         (include-entities #f) (skip-status #f))
  (call/oauth->sxml
   cred 'post #`"/1/account/update_profile.xml"
   (query-params name url location description
                 include-entities skip-status)))

