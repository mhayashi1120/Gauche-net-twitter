# Gauche-net-twitter (forked version)

This module provides an interface to Twitter API using OAuth authentication.

Step by step:

1. Install the package.

   From tarball:

     $ gauche-package install [-S root] Gauche-net-twitter-1.0.tgz

   From source:

     $ git clone git://github.com/shirok/Gauche-net-twitter.git
     $ cd Gauche-net-twitter
     $ ./DIST gen
     $ ./configure
     $ make
     $ make -s check
     $ [sudo] make install

   ('-S root' option or 'sudo' may be required if you want to install
   the package system-wide.)

2. Register your application at http://twitter.com/oauth_clients
   * Check 'Client' in the Application Type question.
   * No need to check 'Use Twitter for login' box.
   * Save "Consumer key" and "Consumer secret" shown in the next screen.

3. Let the user to grant access to his/her twitter account via your client.
   How to handle this depends on your client.  If you (application author)
   just want to grant your application to access *your* twitter account,
   there's a simple script net/twitauth.scm that handles the process.  Run
   it as 'gosh net/twitauth'.   (If you haven't installed the module,
   cd to Gauche-net-twitter and run 'gosh -I. net/twitauth').
   It asks you to type your application's consumer key and consumer secret.

     $ gosh net/twitauth
     Enter consumer key: XXXXXXXXXXXXXXXXXXX
     Enter consumer secret: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx

   Then it shows an URL you should access by your browser.

     Open the following url and type in the shown PIN.
     https://api.twitter.com/oauth/authorize?oauth_token=XXXXXXXXXXXXXXXXXXX
     Input PIN: 

   The page asks you if you grant access to the applicatio or not.
   If you click "Accept", it shows 7-digit PIN.   Type that PIN
   into the above 'Input PIN' prompt.

   Then the script shows information necessary to access to your Twitter
   account.  Save them.

   (
    (consumer-key        . "XXXXXXXXXXXXXXXXXXXX")
    (consumer-secret     . "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    (access-token        . "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    (access-token-secret . "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
   )

   NB: If you intend to distribute your application to others and allow
   them to grant the application's access to their Twitter account, you
   would want to have better UI.  You can design your interaction with
   twitter-authenticate-client procedure described below.


4. In your program, create a <twitter-cred> instance with the above
   information, and use it to call Twitter API.

    (define *cred* (make <twitter-cred>
                     :consumer-key "XXX.....XXX"
                     :consumer-secret "XXX.....XXX"
                     :access-token "XXX......XXX"
                     :access-token-secret "XXX.....XXX"))

    (twitter-update *cred* "Post from my application!")
   


# Module API

[Module] net.twitter

Some twitter API interface come with several flavors.  Procedures
suffixed by /json return JSON representation of the server response,
along the list of message headers.  They are for applications that
needs full access to the server response.  Procedures without suffix,
or different suffix, return more convenient values, so that the
caller won't need to scan JSON. net.twitter such suffixed API return
string object for backward compatibility. Each modularized API 
return correspond typed value belongs to JSON object.

For instance, twitter-followers/json returns two values such as
the following (each result is truncated for conciseness):

gosh> (twitter-followers/ids/json cred :screen-name "chaton_gauche")
  (("ids" . #(75017042 5327762 69605132 151305186
    68190981 18044198 149962169 114554818
    10967962 14988077 19059915 37883768
    15674085 ....))

(("date" "Mon, 07 Jun 2010 02:03:04 GMT")
   ("server" "hi")
   ("status" "200 OK")
   ("x-transaction" "1275876184-68906-26775")
   ("x-ratelimit-limit" "150")
   ("etag" "\"83b847f06bfe0338b8c62c85f39a8294\"")
   ....)

While twitter-followers/ids just returns a list of user ids as string:

  gosh> (twitter-followers/ids cred :screen-name "chaton_gauche")
  ("75017042" "5327762" "69605132" "151305186" "68190981" ...)

In both versions, if the server returns response other than 200,
a condition <twitter-api-error> is signalled.

`net.twitter' module methods as long as having backward compatibility,
otherwise have more usefull methods in almost case. If you want to use
API specific data type, require `net.twitter.friendship' module:

  gosh> (followers/ids cred :screen-name "chaton_gauche")
  (75017042 5327762 69605132 151305186 68190981 ...)

[Class] <twitter-cred>

    An object holding necessary information to access to the user's Twitter
    account.  It has the following instance slots.
  
     consumer-key
     consumer-secret
     access-token
     access-token-secret

[Condition type] <twitter-api-error>

    A condition thrown when twitter server returns a response other
    than 200.  The condition has the following slots.
  
     status        (string) response status code, e.g. "403"
     headers       (list of (string string)) list of response headers.
     body          (string) response body, as is.
     body-sxml     (maybe SXML) if response body is XML, it is parsed and
                   SXML is set to this slots.  Otherwise it is #f.
     body-json     (maybe JSON) if response body is json, it is parsed and
                   JSON is set to this slots.  Otherwise it is #f.

[Function] twitter-authenticate-client consumer-key consumer-secret
                                       :optional input-callback

    Authenticate the client using twitter's PIN-based OAuth authentication
    flow.  First it obtains request-token, then ask the user to access
    a specific URL to grant access by the client.  Once the user grant access,
    Twitter presents a PIN to the user, which should be fed back
    to the procedure to obtain access token and secret.
  
    Once this process completes, the client program can store the access
    token and access token secret to access the user's Twitter account,
    until the user explicitly asks to discard those credentials.  So, 
    in general, this procedure needs to be called once per user per client.
  
    The INPUT-CALLBACK is a procedure that handles user intervention.
    It is called by one argument, the Twitter URL the user should access.
    By default it prints the URL and asks the user to go there and obtain
    PIN, and prompts the user to enter it.  It should return the entered
    PIN in string, or #f to indicate the user aborted the process.
    If the callback returns an empty string, it is called again.
  
    Twitter-authenticate-client returns an instance of <twitter-cred>.

## [Module] net.twitter.account

[Function] update-delivery-device/json (https://api.twitter.com/1.1/account/update_delivery_device.json)

	Sets which device Twitter delivers updates to for the authenticating user.
	Sending none as the device parameter will disable SMS updates.


[Function] update-profile-banner/json (https://api.twitter.com/1.1/account/update_profile_banner.json)

	Uploads a profile banner on behalf of the authenticating user. For best
	results, upload an <5MB image that is exactly 1252px by 626px. Images will
	be resized for a number of display options. Users with an uploaded profile
	banner will have a profile_banner_url node in their
	https://dev.twitter.com/docs/platform-objects/users Users objects. More
	information about sizing variations can be found in
	https://dev.twitter.com/docs/user-profile-images-and-banners User Profile
	Images and Banners and
	https://dev.twitter.com/docs/api/1.1/get/users/profile_banner GET
	users/profile_banner . Profile banner images are processed asynchronously.
	The profile_banner_url and its variant sizes will not necessary be
	available directly after upload.


[Function] update-profile/json (https://api.twitter.com/1.1/account/update_profile.json)

	Sets values that users are able to set under the "Account" tab of their
	settings page. Only the parameters specified will be updated.


[Function] update-profile-colors/json (https://api.twitter.com/1.1/account/update_profile_colors.json)

	Sets one or more hex values that control the color scheme of the
	authenticating user's profile page on twitter.com. Each parameter's value
	must be a valid hexidecimal value, and may be either three or six
	characters (ex: #fff or #ffffff).


[Function] update-profile-background-image/json (https://api.twitter.com/1.1/account/update_profile_background_image.json)

	Updates the authenticating user's profile background image. This method
	can also be used to enable or disable the profile background image.
	Although each parameter is marked as optional, at least one of image ,
	tile or use must be provided when making this request.


[Function] update-profile-image/json (https://api.twitter.com/1.1/account/update_profile_image.json)

	Updates the authenticating user's profile image. Note that this method
	expects raw multipart data, not a URL to an image. This method
	asynchronously processes the uploaded file before updating the user's
	profile image URL. You can either update your local cache the next time
	you request the user's information, or, at least 5 seconds after uploading
	the image, ask for the updated URL using
	https://dev.twitter.com/docs/api/1.1/get/users/show GET users/show .


[Function] settings-update/json (https://api.twitter.com/1.1/account/settings.json)

	Updates the authenticating user's settings.


[Function] settings/json (https://api.twitter.com/1.1/account/settings.json)

	Returns settings (including current trend, geo and sleep time information)
	for the authenticating user.


[Function] verify-credentials/json (https://api.twitter.com/1.1/account/verify_credentials.json)

	Returns an HTTP 200 OK response code and a representation of the
	requesting user if authentication was successful; returns a 401 status
	code and an error message if not. Use this method to test if supplied user
	credentials are valid.



## [Module] net.twitter.help

[Function] privacy/json (https://api.twitter.com/1.1/help/privacy.json)

	Returns http://twitter.com/privacy Twitter's Privacy Policy .


[Function] tos/json (https://api.twitter.com/1.1/help/tos.json)

	Returns the http://twitter.com/tos Twitter Terms of Service in the
	requested format. These are not the same as the
	https://dev.twitter.com/terms/api-terms Developer Rules of the Road .


[Function] rate-limit-status/json (https://api.twitter.com/1.1/application/rate_limit_status.json)

	Returns the current rate limits for methods belonging to the specified
	resource families. Each 1.1 API resource belongs to a "resource family"
	which is indicated in its method documentation. You can typically
	determine a method's resource family from the first component of the path
	after the resource version. This method responds with a map of methods
	belonging to the families specified by the resources parameter, the
	current remaining uses for each of those resources within the current rate
	limiting window, and its expiration time in
	http://en.wikipedia.org/wiki/Unix_time epoch time . It also includes a
	rate_limit_context field that indicates the current access token context.
	You may also issue requests to this method without any parameters to
	receive a map of all rate limited GET methods. If your application only
	uses a few of methods, please explicitly provide a resources parameter
	with the specified resource families you work with. Read more about
	https://dev.twitter.com/docs/rate-limiting/1.1 REST API Rate Limiting in
	v1.1 and /docs/rate-limiting/1.1/limits review the limits .


[Function] languages/json (https://api.twitter.com/1.1/help/languages.json)

	Returns the list of languages supported by Twitter along with their ISO
	639-1 code. The ISO 639-1 code is the two letter value to use if you
	include lang with any of your requests.


[Function] configuration/json (https://api.twitter.com/1.1/help/configuration.json)

	Returns the current configuration used by Twitter including twitter.com
	slugs which are not usernames, maximum photo resolutions, and t.co URL
	lengths. It is recommended applications request this endpoint when they
	are loaded, but no more than once a day.



## [Module] net.twitter.favorite

[Function] destroy/json (https://api.twitter.com/1.1/favorites/destroy.json)

	Un-favorites the status specified in the ID parameter as the
	authenticating user. Returns the un-favorited status in the requested
	format when successful. This process invoked by this method is
	asynchronous. The immediately returned status may not indicate the
	resultant favorited status of the tweet. A 200 OK response from this
	method will indicate whether the intended action was successful or not.


[Function] create/json (https://api.twitter.com/1.1/favorites/create.json)

	Favorites the status specified in the ID parameter as the authenticating
	user. Returns the favorite status when successful. This process invoked by
	this method is asynchronous. The immediately returned status may not
	indicate the resultant favorited status of the tweet. A 200 OK response
	from this method will indicate whether the intended action was successful
	or not.


[Function] list/json (https://api.twitter.com/1.1/favorites/list.json)

	Returns the 20 most recent Tweets favorited by the authenticating or
	specified user.



## [Module] net.twitter.search

[Function] search-tweets/json (https://api.twitter.com/1.1/search/tweets.json)

	Returns a collection of relevant
	https://dev.twitter.com/docs/platform-objects/tweets Tweets matching a
	specified query. Please note that Twitter's search service and, by
	extension, the Search API is not meant to be an exhaustive source of
	Tweets. Not all Tweets will be indexed or made available via the search
	interface. In API v1.1, the response format of the Search API has been
	improved to return https://dev.twitter.com/docs/platform-objects/tweets
	Tweet objects more similar to the objects you'll find across the REST API
	and platform. You may need to tolerate some inconsistencies and variance
	in perspectival values (fields that pertain to the perspective of the
	authenticating user) and embedded user objects. To learn how to use
	https://twitter.com/search Twitter Search effectively, consult our guide
	to https://dev.twitter.com/docs/using-search Using the Twitter Search API
	. See https://dev.twitter.com/docs/working-with-timelines Working with
	Timelines to learn best practices for navigating results by since_id and
	max_id .



## [Module] net.twitter.geo

[Function] place/json (https://api.twitter.com/1.1/geo/place.json)

	Creates a new place object at the given latitude and longitude. Before
	creating a place you need to query
	https://dev.twitter.com/docs/api/1.1/get/geo/similar_places GET
	geo/similar_places with the latitude, longitude and name of the place you
	wish to create. The query will return an array of places which are similar
	to the one you wish to create, and a token . If the place you wish to
	create isn't in the returned array you can use the token with this method
	to create a new one. Learn more about
	https://dev.twitter.com/docs/finding-tweets-about-places Finding Tweets
	about Places .


[Function] id/json (https://api.twitter.com/1.1/geo/id/:place_id.json)

	Returns all the information about a known
	https://dev.twitter.com/docs/platform-objects/places place .


[Function] reverse-geocode/json (http://api.twitter.com/1.1/geo/reverse_geocode.json)

	Given a latitude and a longitude, searches for up to 20 places that can be
	used as a place_id when updating a status. This request is an informative
	call and will deliver generalized results about geography.


[Function] similar-places/json (https://api.twitter.com/1.1/geo/similar_places.json)

	Locates https://dev.twitter.com/docs/platform-objects/places places near
	the given coordinates which are similar in name. Conceptually you would
	use this method to get a list of known places to choose from first. Then,
	if the desired place doesn't exist, make a request to
	https://dev.twitter.com/docs/api/1.1/post/geo/place POST geo/place to
	create a new one. The token contained in the response is the token needed
	to be able to create a new place.


[Function] search/json (https://api.twitter.com/1.1/geo/search.json)

	Search for places that can be attached to a statuses/update. Given a
	latitude and a longitude pair, an IP address, or a name, this request will
	return a list of all the valid places that can be used as the place_id
	when updating a status. Conceptually, a query can be made from the user's
	location, retrieve a list of places, have the user validate the location
	he or she is at, and then send the ID of this location with a call to
	https://dev.twitter.com/docs/api/1.1/post/statuses/update POST
	statuses/update . This is the recommended method to use find places that
	can be attached to statuses/update. Unlike
	https://dev.twitter.com/docs/api/1.1/get/geo/reverse_geocode GET
	geo/reverse_geocode which provides raw data access, this endpoint can
	potentially re-order places with regards to the user who is authenticated.
	This approach is also preferred for interactive place matching with the
	user.



## [Module] net.twitter.dm

[Function] destroy/json (https://api.twitter.com/1.1/direct_messages/destroy.json)

	Destroys the direct message specified in the required ID parameter. The
	authenticating user must be the recipient of the specified direct message.
	Important : This method requires an access token with RWD (read, write &
	direct message) permissions. Consult
	https://dev.twitter.com/docs/application-permission-model The Application
	Permission Model for more information.


[Function] new/json (https://api.twitter.com/1.1/direct_messages/new.json)

	Sends a new direct message to the specified user from the authenticating
	user. Requires both the user and text parameters and must be a POST.
	Returns the sent message in the requested format if successful.


[Function] sent/json (https://api.twitter.com/1.1/direct_messages/sent.json)

	Returns the 20 most recent direct messages sent by the authenticating
	user. Includes detailed information about the sender and recipient user.
	You can request up to 200 direct messages per call, up to a maximum of 800
	outgoing DMs. Important : This method requires an access token with RWD
	(read, write & direct message) permissions. Consult
	https://dev.twitter.com/docs/application-permission-model The Application
	Permission Model for more information.


[Function] list/json (https://api.twitter.com/1.1/direct_messages.json)

	Returns the 20 most recent direct messages sent to the authenticating
	user. Includes detailed information about the sender and recipient user.
	You can request up to 200 direct messages per call, up to a maximum of 800
	incoming DMs. Important : This method requires an access token with RWD
	(read, write & direct message) permissions. Consult
	https://dev.twitter.com/docs/application-permission-model The Application
	Permission Model for more information.


[Function] show/json (https://api.twitter.com/1.1/direct_messages/show.json)

	Returns a single direct message, specified by an id parameter. Like the
	/1.1/direct_messages.format request, this method will include the user
	objects of the sender and recipient. Important : This method requires an
	access token with RWD (read, write & direct message) permissions. Consult
	https://dev.twitter.com/docs/application-permission-model The Application
	Permission Model for more information.



## [Module] net.twitter.friendship

[Function] friends-incoming/json (https://api.twitter.com/1.1/friendships/incoming.json)

	Returns a collection of numeric IDs for every user who has a pending
	request to follow the authenticating user.


[Function] friends-lookup/json (http://api.twitter.com/1.1/friendships/lookup.json)

	Returns the relationships of the authenticating user to the
	comma-separated list of up to 100 screen_names or user_ids provided.
	Values for connections can be: following , following_requested ,
	followed_by , none .


[Function] friends-no-retweets/ids/json (https://api.twitter.com/1.1/friendships/no_retweets/ids.json)

	Returns a collection of user_ids that the currently authenticated user
	does not want to receive retweets from. Use
	https://dev.twitter.com/docs/api/1.1/post/friendships/update POST
	friendships/update to set the "no retweets" status for a given user
	account on behalf of the current user.


[Function] friends-outgoing/json (http://api.twitter.com/1.1/friendships/outgoing.format)

	Returns a collection of numeric IDs for every protected user for whom the
	authenticating user has a pending follow request.


[Function] update/json (http://api.twitter.com/1.1/friendships/update.json)

	Allows one to enable or disable retweets and device notifications from the
	specified user.


[Function] destroy/json (https://api.twitter.com/1.1/friendships/destroy.json)

	Allows the authenticating user to unfollow the user specified in the ID
	parameter. Returns the unfollowed user in the requested format when
	successful. Returns a string describing the failure condition when
	unsuccessful. Actions taken in this method are asynchronous and changes
	will be eventually consistent.


[Function] create/json (https://api.twitter.com/1.1/friendships/create.json)

	Allows the authenticating users to follow the user specified in the ID
	parameter. Returns the befriended user in the requested format when
	successful. Returns a string describing the failure condition when
	unsuccessful. If you are already friends with the user a HTTP 403 may be
	returned, though for performance reasons you may get a 200 OK message even
	if the friendship already exists. Actions taken in this method are
	asynchronous and changes will be eventually consistent.


[Function] show/json (http://api.twitter.com/1.1/friendships/show.json)

	Returns detailed information about the relationship between two arbitrary
	users.


[Function] followers/list/json (https://api.twitter.com/1.1/followers/list.json)

	Returns a cursored collection of user objects for users following the
	specified user. At this time, results are ordered with the most recent
	following first &mdash; however, this ordering is subject to unannounced
	change and eventual consistency issues. Results are given in groups of 20
	users and multiple "pages" of results can be navigated through using the
	next_cursor value in subsequent requests. See
	https://dev.twitter.com/docs/misc/cursoring Using cursors to navigate
	collections for more information.


[Function] followers/ids/json (https://api.twitter.com/1.1/followers/ids.json)

	Returns a cursored collection of user IDs for every user following the
	specified user. At this time, results are ordered with the most recent
	following first &mdash; however, this ordering is subject to unannounced
	change and eventual consistency issues. Results are given in groups of
	5,000 user IDs and multiple "pages" of results can be navigated through
	using the next_cursor value in subsequent requests. See
	https://dev.twitter.com/docs/misc/cursoring Using cursors to navigate
	collections for more information. This method is especially powerful when
	used in conjunction with
	https://dev.twitter.com/docs/api/1.1/get/users/lookup GET users/lookup , a
	method that allows you to convert user IDs into full
	https://dev.twitter.com/docs/platform-objects/users user objects in bulk.


[Function] friends/list/json (https://api.twitter.com/1.1/friends/list.json)

	Returns a cursored collection of user objects for every user the specified
	user is following (otherwise known as their "friends"). At this time,
	results are ordered with the most recent following first &mdash; however,
	this ordering is subject to unannounced change and eventual consistency
	issues. Results are given in groups of 20 users and multiple "pages" of
	results can be navigated through using the next_cursor value in subsequent
	requests. See https://dev.twitter.com/docs/misc/cursoring Using cursors to
	navigate collections for more information.


[Function] friends/ids/json (https://api.twitter.com/1.1/friends/ids.json)

	Returns a cursored collection of user IDs for every user the specified
	user is following (otherwise known as their "friends"). At this time,
	results are ordered with the most recent following first &mdash; however,
	this ordering is subject to unannounced change and eventual consistency
	issues. Results are given in groups of 5,000 user IDs and multiple "pages"
	of results can be navigated through using the next_cursor value in
	subsequent requests. See https://dev.twitter.com/docs/misc/cursoring Using
	cursors to navigate collections for more information. This method is
	especially powerful when used in conjunction with
	https://dev.twitter.com/docs/api/1.1/get/users/lookup GET users/lookup , a
	method that allows you to convert user IDs into full
	https://dev.twitter.com/discussions/7827 user objects in bulk.



## [Module] net.twitter.user

[Function] report-spam/json (https://api.twitter.com/1.1/users/report_spam.json)

	Report the specified user as a spam account to Twitter. Additionally
	performs the equivalent of
	https://dev.twitter.com/docs/api/1.1/post/blocks/create POST blocks/create
	on behalf of the authenticated user.


[Function] profile-banner/json (https://api.twitter.com/1.1/users/profile_banner.json)

	Returns a map of the available size variations of the specified user's
	profile banner. If the user has not uploaded a profile banner, a HTTP 404
	will be served instead. This method can be used instead of string
	manipulation on the profile_banner_url returned in user objects as
	described in https://dev.twitter.com/docs/user-profile-images-and-banners
	User Profile Images and Banners .


[Function] suggestion/members/json (http://api.twitter.com/1.1/users/suggestions/:slug/members.json)

	Access the users in a given category of the Twitter suggested user list
	and return their most recent status if they are not a protected user.


[Function] suggestions/category/json (http://api.twitter.com/1.1/users/suggestions/:slug.json)

	Access the users in a given category of the Twitter suggested user list.
	It is recommended that applications cache this data for no more than one
	hour.


[Function] suggestions/json (http://api.twitter.com/1.1/users/suggestions.format)

	Access to Twitter's suggested user list. This returns the list of
	suggested user categories. The category can be used in
	https://dev.twitter.com/docs/api/1.1/get/users/suggestions/%3Aslug GET
	users/suggestions/:slug to get the users in that category.


[Function] search/json (https://api.twitter.com/1.1/users/search.json)

	Provides a simple, relevance-based search interface to public user
	accounts on Twitter. Try querying by topical interest, full name, company
	name, location, or other criteria. Exact match searches are not supported.
	Only the first 1,000 matching results are available.


[Function] lookup/json (https://api.twitter.com/1.1/users/lookup.json)

	Returns fully-hydrated https://dev.twitter.com/docs/platform-objects/users
	user objects for up to 100 users per request, as specified by
	comma-separated values passed to the user_id and/or screen_name
	parameters. This method is especially useful when used in conjunction with
	collections of user IDs returned from
	https://dev.twitter.com/docs/api/1.1/get/friends/ids GET friends/ids and
	https://dev.twitter.com/docs/api/1.1/get/followers/ids GET followers/ids .
	https://dev.twitter.com/docs/api/1.1/get/users/show GET users/show is used
	to retrieve a single user object.


[Function] show/json (http://api.twitter.com/1.1/users/show.json)

	Returns a https://dev.twitter.com/docs/platform-objects/users variety of
	information about the user specified by the required user_id or
	screen_name parameter. The author's most recent Tweet will be returned
	inline when possible.
	https://dev.twitter.com/docs/api/1.1/get/users/lookup GET users/lookup is
	used to retrieve a bulk collection of user objects.



## [Module] net.twitter.status

[Function] oembed/json (https://api.twitter.com/1.1/statuses/oembed.json)

	Returns information allowing the creation of an embedded representation of
	a Tweet on third party sites. See the http://oembed.com/ oEmbed
	specification for information about the response format. While this
	endpoint allows a bit of customization for the final appearance of the
	embedded Tweet, be aware that the appearance of the rendered Tweet may
	change over time to be consistent with Twitter's
	https://dev.twitter.com/terms/display-requirements Display Requirements .
	Do not rely on any class or id parameters to stay constant in the returned
	markup.


[Function] retweets/json (https://api.twitter.com/1.1/statuses/retweets/:id.json)

	Returns up to 100 of the first retweets of a given tweet.


[Function] retweet/json (https://api.twitter.com/1.1/statuses/retweet/:id.json)

	Retweets a tweet. Returns the
	https://dev.twitter.com/docs/platform-objects/tweets original tweet with
	retweet details embedded.


[Function] destroy/json (https://api.twitter.com/1.1/statuses/destroy/:id.json)

	Destroys the status specified by the required ID parameter. The
	authenticating user must be the author of the specified status. Returns
	the destroyed status if successful.


[Function] update-with-media/json (https://api.twitter.com/1.1/statuses/update_with_media.json)

	Updates the authenticating user's current status and attaches media for
	upload. In other words, it creates a Tweet with a picture attached. Unlike
	/docs/api/1.1/post/statuses/update POST statuses/update , this method
	expects raw multipart data. Your POST request's Content-Type should be set
	to multipart/form-data with the media[] parameter The Tweet text will be
	rewritten to include the media URL(s), which will reduce the number of
	characters allowed in the Tweet text. If the URL(s) cannot be appended
	without text truncation, the tweet will be rejected and this method will
	return an HTTP 403 error. Important : In API v1.1, you now use
	api.twitter.com as the domain instead of upload.twitter.com. We strongly
	recommend using SSL with this method.


[Function] update/json (https://api.twitter.com/1.1/statuses/update.json)

	Updates the authenticating user's current status, also known as tweeting.
	To upload an image to accompany the tweet, use
	https://dev.twitter.com/docs/api/1.1/post/statuses/update_with_media POST
	statuses/update_with_media . For each update attempt, the update text is
	compared with the authenticating user's recent tweets. Any attempt that
	would result in duplication will be blocked, resulting in a 403 error.
	Therefore, a user cannot submit the same status twice in a row. While not
	rate limited by the API a user is limited in the number of tweets they can
	create at a time. If the number of updates posted by the user reaches the
	current allowed limit this method will return an HTTP 403 error.


[Function] show/json (https://api.twitter.com/1.1/statuses/show.json)

	Returns a single https://dev.twitter.com/docs/platform-objects/tweets
	Tweet , specified by the id parameter. The Tweet's author will also be
	embedded within the tweet. See
	https://dev.twitter.com/docs/embedded-timelines Embeddable Timelines ,
	https://dev.twitter.com/docs/embedded-tweets Embeddable Tweets , and
	https://dev.twitter.com/docs/api/1.1/get/statuses/oembed GET
	statuses/oembed for tools to render Tweets according to
	https://dev.twitter.com/terms/display-requirements Display Requirements .



## [Module] net.twitter.trends

[Function] place/json (https://api.twitter.com/1.1/trends/place.json)

	Returns the top 10 trending topics for a specific WOEID , if trending
	information is available for it. The response is an array of "trend"
	objects that encode the name of the trending topic, the query parameter
	that can be used to search for the topic on http://search.twitter.com/ me
	Twitter Search , and the Twitter Search URL. This information is cached
	for 5 minutes. Requesting more frequently than that will not return any
	more data, and will count against your rate limit usage.


[Function] closest/json (https://api.twitter.com/1.1/trends/closest.json)

	Returns the locations that Twitter has trending topic information for,
	closest to a specified location. The response is an array of "locations"
	that encode the location's WOEID and some other human-readable information
	such as a canonical name and country the location belongs in. A WOEID is a
	http://developer.yahoo.com/geo/geoplanet/ external Yahoo! Where On Earth
	ID .


[Function] available/json (https://api.twitter.com/1.1/trends/available.json)

	Returns the locations that Twitter has trending topic information for. The
	response is an array of "locations" that encode the location's WOEID and
	some other human-readable information such as a canonical name and country
	the location belongs in. A WOEID is a
	http://developer.yahoo.com/geo/geoplanet/ external Yahoo! Where On Earth
	ID .



## [Module] net.twitter.list

[Function] subscriptions/json (https://api.twitter.com/1.1/lists/subscriptions.json)

	Obtain a collection of the lists the specified user is subscribed to, 20
	lists per page by default. Does not include the user's own lists.


[Function] memberships/json (https://api.twitter.com/1.1/lists/memberships.json)

	Returns the lists the specified user has been added to. If user_id or
	screen_name are not provided the memberships for the authenticating user
	are returned.


[Function] subscriber-destroy/json (https://api.twitter.com/1.1/lists/subscribers/destroy.json)

	Unsubscribes the authenticated user from the specified list.


[Function] subscriber-create/json (https://api.twitter.com/1.1/lists/subscribers/create.json)

	Subscribes the authenticated user to the specified list.


[Function] subscriber-show/json (https://api.twitter.com/1.1/lists/subscribers/show.json)

	Check if the specified user is a subscriber of the specified list. Returns
	the user if they are subscriber.


[Function] subscribers/json (https://api.twitter.com/1.1/lists/subscribers.json)

	Returns the subscribers of the specified list. Private list subscribers
	will only be shown if the authenticated user owns the specified list.


[Function] member-destroy-all/json (https://api.twitter.com/1.1/lists/members/destroy_all.json)

	Removes multiple members from a list, by specifying a comma-separated list
	of member ids or screen names. The authenticated user must own the list to
	be able to remove members from it. Note that lists can't have more than
	500 members, and you are limited to removing up to 100 members to a list
	at a time with this method. Please note that there can be issues with
	lists that rapidly remove and add memberships. Take care when using these
	methods such that you are not too rapidly switching between removals and
	adds on the same list.


[Function] member-destroy/json (https://api.twitter.com/1.1/lists/members/destroy.json)

	Removes the specified member from the list. The authenticated user must be
	the list's owner to remove members from the list.


[Function] members-create-all/json (https://api.twitter.com/1.1/lists/members/create_all.json)

	Adds multiple members to a list, by specifying a comma-separated list of
	member ids or screen names. The authenticated user must own the list to be
	able to add members to it. Note that lists can't have more than 500
	members, and you are limited to adding up to 100 members to a list at a
	time with this method. Please note that there can be issues with lists
	that rapidly remove and add memberships. Take care when using these
	methods such that you are not too rapidly switching between removals and
	adds on the same list.


[Function] member-create/json (https://api.twitter.com/1.1/lists/members/create.json)

	Add a member to a list. The authenticated user must own the list to be
	able to add members to it. Note that lists can't have more than 500
	members.


[Function] member-show/json (https://api.twitter.com/1.1/lists/members/show.json)

	Check if the specified user is a member of the specified list.


[Function] members/json (https://api.twitter.com/1.1/lists/members.json)

	Returns the members of the specified list. Private list members will only
	be shown if the authenticated user owns the specified list.


[Function] destroy/json (https://api.twitter.com/1.1/lists/destroy.json)

	Deletes the specified list. The authenticated user must own the list to be
	able to destroy it.


[Function] update/json (https://api.twitter.com/1.1/lists/update.json)

	Updates the specified list. The authenticated user must own the list to be
	able to update it.


[Function] create/json (https://api.twitter.com/1.1/lists/create.json)

	Creates a new list for the authenticated user. Note that you can't create
	more than 20 lists per account.


[Function] statuses/json (https://api.twitter.com/1.1/lists/statuses.json)

	Returns a timeline of tweets authored by members of the specified list.
	Retweets are included by default. Use the include_rts=false parameter to
	omit retweets. https://dev.twitter.com/docs/embedded-timelines Embedded
	Timelines is a great way to embed list timelines on your website.


[Function] show/json (https://api.twitter.com/1.1/lists/show.json)

	Returns the specified list. Private lists will only be shown if the
	authenticated user owns the specified list.


[Function] list/json (http://api.twitter.com/1.1/lists/list.json)

	Returns all lists the authenticating or specified user subscribes to,
	including their own. The user is specified using the user_id or
	screen_name parameters. If no user is given, the authenticating user is
	used. This method used to be GET lists in version 1.0 of the API and has
	been renamed for consistency with other call.



## [Module] net.twitter.block

[Function] destroy/json (https://api.twitter.com/1.1/blocks/destroy.json)

	Un-blocks the user specified in the ID parameter for the authenticating
	user. Returns the un-blocked user in the requested format when successful.
	If relationships existed before the block was instated, they will not be
	restored.


[Function] create/json (https://api.twitter.com/1.1/blocks/create.json)

	Blocks the specified user from following the authenticating user. In
	addition the blocked user will not show in the authenticating users
	mentions or timeline (unless retweeted by another user). If a follow or
	friend relationship exists it is destroyed.


[Function] ids/json (https://api.twitter.com/1.1/blocks/ids.json)

	Returns an array of numeric user ids the authenticating user is blocking.
	Important On October 15, 2012 this method will become cursored by default,
	altering the default response format. See
	https://dev.twitter.com/docs/misc/cursoring Using cursors to navigate
	collections for more details on how cursoring works.


[Function] list/json (https://api.twitter.com/1.1/blocks/list.json)

	Returns a collection of
	https://dev.twitter.com/docs/platform-objects/users user objects that the
	authenticating user is blocking. Important On October 15, 2012 this method
	will become cursored by default, altering the default response format. See
	https://dev.twitter.com/docs/misc/cursoring Using cursors to navigate
	collections for more details on how cursoring works.



## [Module] net.twitter.saved-search

[Function] destroy/json (https://api.twitter.com/1.1/saved_searches/destroy/:id.json)

	Destroys a saved search for the authenticating user. The authenticating
	user must be the owner of saved search id being destroyed.


[Function] create/json (https://api.twitter.com/1.1/saved_searches/create.json)

	Create a new saved search for the authenticated user. A user may only have
	25 saved searches.


[Function] show/json (https://api.twitter.com/1.1/saved_searches/show/:id.json)

	Retrieve the information for the saved search represented by the given id.
	The authenticating user must be the owner of saved search ID being
	requested.


[Function] list/json (https://api.twitter.com/1.1/saved_searches/list.json)

	Returns the authenticated user's saved search queries.



## [Module] net.twitter.timeline

[Function] retweets-of-me/json (https://api.twitter.com/1.1/statuses/retweets_of_me.json)

	Returns the most recent tweets authored by the authenticating user that
	have recently been retweeted by others. This timeline is a subset of the
	user's https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline GET
	statuses/user_timeline . See
	https://dev.twitter.com/docs/working-with-timelines Working with Timelines
	for instructions on traversing timelines.


[Function] mentions-timeline/json (https://api.twitter.com/1.1/statuses/mentions_timeline.json)

	Returns the 20 most recent mentions (tweets containing a users's
	@screen_name) for the authenticating user. The timeline returned is the
	equivalent of the one seen when you view http://twitter.com/mentions your
	mentions on twitter.com. This method can only return up to 800 tweets. See
	https://dev.twitter.com/docs/working-with-timelines Working with Timelines
	for instructions on traversing timelines.


[Function] user-timeline/json (https://api.twitter.com/1.1/statuses/user_timeline.json)

	Returns a collection of the most recent
	https://dev.twitter.com/docs/platform-objects/tweets Tweets posted by the
	https://dev.twitter.com/docs/platform-objects/users user indicated by the
	screen_name or user_id parameters. User timelines belonging to protected
	users may only be requested when the authenticated user either "owns" the
	timeline or is an approved follower of the owner. The timeline returned is
	the equivalent of the one seen when you view a user's profile on
	http://twitter.com twitter.com . This method can only return up to 3,200
	of a user's most recent Tweets. Native retweets of other statuses by the
	user is included in this total, regardless of whether include_rts is set
	to false when requesting this resource. See
	https://dev.twitter.com/docs/working-with-timelines Working with Timelines
	for instructions on traversing timelines. See
	https://dev.twitter.com/docs/embedded-timelines Embeddable Timelines ,
	https://dev.twitter.com/docs/embedded-tweets Embeddable Tweets , and
	https://dev.twitter.com/docs/api/1.1/get/statuses/oembed GET
	statuses/oembed for tools to render Tweets according to
	https://dev.twitter.com/terms/display-requirements Display Requirements .


[Function] home-timeline/json (https://api.twitter.com/1.1/statuses/home_timeline.json)

	Returns a collection of the most recent
	https://dev.twitter.com/docs/platform-objects/tweets Tweets and retweets
	posted by the authenticating user and the users they follow. The home
	timeline is central to how most users interact with the Twitter service.
	Up to 800 Tweets are obtainable on the home timeline. It is more volatile
	for users that follow many users or follow users who tweet frequently. See
	https://dev.twitter.com/docs/working-with-timelines Working with Timelines
	for instructions on traversing timelines efficiently.

## [Module] net.twitter.stream

All streaming api accepts PROC which accept a json object called each time 
stream object is arrived from Twitter server. PROC must handle error if you
don't want to disconnect from server everytime to meet client error.

All streaming api accepts RAISE-ERROR? and ERROR-HANDLER keyword which controls
reconnect behavior. ERROR-HANDLER is a  procedure which accept one error object
as argument. RAISE-ERROR? #t means raising error every time disconnect from server.
Otherwise twitter/stream.scm follow twitter reconnecting instructions.
https://dev.twitter.com/docs/streaming-apis/connecting#Reconnecting

# Credits

This module is based on the code brewed among several blogs.

By Saito Atsushi: http://d.hatena.ne.jp/SaitoAtsushi/20100429/1272545442

By tana-laevatein: http://d.hatena.ne.jp/tana-laevatein/20100505/1273025284

By sirocco634: http://d.hatena.ne.jp/sirocco634/20100605#1275743091


