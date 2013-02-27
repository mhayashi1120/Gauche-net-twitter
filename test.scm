;;;
;;; Test net.twitter
;;;

(use gauche.test)

(use gauche.process)
(use file.util)
(use net.favotter)
(use net.twitter)
(use net.twitter.account)
(use net.twitter.auth)
(use net.twitter.block)
(use net.twitter.core)
(use net.twitter.direct-message)
(use net.twitter.friendship)
(use net.twitter.geo)
(use net.twitter.help)
(use net.twitter.list)
(use net.twitter.saved-search)
(use net.twitter.search)
(use net.twitter.timeline)
(use net.twitter.status)
(use net.twitter.user)
(use net.twitter.favorite)
(use rfc.http)
(use rfc.uri)
(use srfi-1)
(use srfi-13)
(use srfi-19)
(use srfi-27)
(use sxml.sxpath)
(use util.list)

(test-start "net.twitter")

(test-module 'net.twitter.user)
(test-module 'net.twitter.status)
(test-module 'net.twitter.timeline)
(test-module 'net.twitter.stream)
(test-module 'net.twitter.search)
(test-module 'net.twitter.saved-search)
(test-module 'net.twitter.list)
(test-module 'net.twitter.help)
(test-module 'net.twitter.friendship)
(test-module 'net.twitter.favorite)
(test-module 'net.twitter.direct-message)
(test-module 'net.twitter.core)
(test-module 'net.twitter.block)
(test-module 'net.twitter.auth)
(test-module 'net.twitter.account)
(test-module 'net.twitter.geo)
(test-module 'net.favotter)
(test-module 'net.twitter)

(test-end)



