CHANGELOG
================================
## v.3.10.0 (2017-01-15)
### Changed
* Uses API v1.6 by default

## v.3.9.0 (2017-08-16)
### Added
* Support for PYLON Reference data API

## v.3.8.0 (2017-05-23)
### Added
* Support for PYLON Task API
* Ads explicit support for additional HTTP response codes

### Changed
* Uses API v1.5 by default

## v.3.7.2 (2016-11-08)
### Fixes
* Uses correct timestamp params in PYLON Sample API calls. `start_time` -> `start` and `end_time` - `end`

## v.3.7.1 (2016-10-06)
### Added
* Explicit support for 500 and 502 responses from the API
### Fixes
* Resolves [#86](https://github.com/datasift/datasift-ruby/issues/86); not handling 502 responses well

## v.3.7.0 (2016-08-04)
### Added
* Support for an `analyze_queries` parameter for Account Identity Limits

### Changed
* Minor fixes for Rubocop

## v.3.6.2 (2016-06-03)
### Fixed
* Corrected params used in the `managed_source_auth.remove()` method. Thanks [@zenovich](https://github.com/zenovich)

## v.3.6.1 (2016-03-08)
### Fixed
* Use API v1.3 by default

## v.3.6.0 (2016-03-08)
### Added
* Support for the [/pylon/update](http://dev.datasift.com/docs/platform/api/rest-api/endpoints/pylonupdate) API endpoint
* Support for [API v1.3](http://dev.datasift.com/docs/platform/api/api-changelog)

## v.3.5.2 (2016-11-08)
### Fixes
* Uses correct timestamp params in PYLON Sample API calls. `start_time` -> `start` and `end_time` - `end`

## v.3.5.1 (2016-10-06)
### Added
* Explicit support for 500 and 502 responses from the API
### Fixes
* Resolves [#86](https://github.com/datasift/datasift-ruby/issues/86); not handling 502 responses well

## v.3.5.0 (2015-11-13)
### Added
* Support for the `/account/usage` API endpoint
* Added explicit support for 412, 415, 503 and 504 HTTP error responses
* Support for the [/pylon/sample](http://dev.datasift.com/docs/platform/api/rest-api/endpoints/pylonsample) API endpoint. Full details about the feature can be found in our [platform release notes](http://community.datasift.com/t/pylon-1-6-release-notes/1859)

### Changed
* Only set ```Content-Type``` HTTP header for POST/PUT requests; it's not necessary unless we are passing a request entity
* Teased out some minor performance enhancements by allocating fewer objects on each request
* Loosen some Gem dependancies. Successfully tested against [rest-client](https://github.com/rest-client/rest-client) v2.0.0

## v.3.4.0 (2015-08-20)
### Added
* Support for [Open Data Processing](https://datasift.com/products/open-data-processing-for-twitter/) batch uploads (Thanks [@giovannelli](https://github.com/giovannelli))
* Explicit support for 413 and 422 errors from API
* Ability to get at API response headers using the ```object.response``` accessor. (Thanks again [@giovannelli](https://github.com/giovannelli))

### Changed
* Bumped [rest-client](https://github.com/rest-client/rest-client) dependency to ~> 1.8
* The OpenSSL version you select within the DataSift gem no longer changes the default OpenSSL version in your wider application; it only affects API calls made by the DataSift gem to DataSift's API

## v.3.3.0 (2015-08-05)
### Added
* Explicit support for 429 errors from the API
* PYLON Nested query example

### Changed
* Default API version to 1.2
* Improved Managed Sources examples (added dedicated Facebook Pages example)

### Removed
* References to the Twitter data source (being deprecated on August 13th, 2015)

## v.3.2.0 (2015-05-13)
### Added
* Support for [PYLON API](http://dev.datasift.com/docs/platform/api/rest-api/endpoints)
* Support for [Account Identities API](http://dev.datasift.com/docs/platform/api/rest-api/endpoints)
* Adds opts for Managed Sources create/update endpoints to allow passing of 'validate' param
* Support for HTTP 409 Conflict error
* Support for HTTP 410 Gone error
* Comprehensive Yard Docs for all classes and methods
* Due to API v1.1 change, we've added support for ```include_finished``` and ```all``` parameters when making calls to the ```/push/get``` API endpoint
* Due to the API v1.1 change, a ```delivery_count``` field has been added to the main object, and individual chunks in the response from ```/historics/get``` calls
* Due to the API v1.1 change, an ```interaction_count``` field has been added to the respomse from ```/push/get``` API calls
* The ```dpu()``` method now also accepts the ```historics_id``` parameter, which allows you to get the DPU cost of an Historics query

### Changed
* Some refactoring for the Rubocop across the library
* We now use [VCR](https://github.com/vcr/vcr) in our test suite for all outbound API calls
* Updated some methods due to deprecations in the Ruby language
* Use DataSift API v1.1 by default
* Due to the API v1.1 change, /usage and /balance API calls will now return an empty Object rather than an empy Array when there is no data available

### Deprecated
* Support for Ruby 1.x is being dropped in the next major release; 4.0.0
* Due to the API v1.1 change, the ```volume_info``` field has been removed from ```/historics/get``` API calls

v.3.1.5 (2015-04-16)
--------------------
####Fixes
* Resolves #73; Ensure we can pass the ```validate``` flag and other optional params on /source/create and /update API calls

v.3.1.4 (2015-02-10)
--------------------
####Improvements
* Use TLSv1.2 by default, and allow users to specify SSL version in config with the :ssl_version parameter
* Minor refactoring according to Rubocop style guides
* Test against Ruby 2.2 on Travis

v.3.1.3 (2014-12-02)
--------------------
####Fixes
* Resolves #57; ensures config is not overridden when initializing LiveStream
* Relaxed version dependency on multi_json to resolve #67

v.3.1.2 (2014-08-28)
--------------------

####Improvements
* Relaxed gem dependencies; resolves [#65](https://github.com/datasift/datasift-ruby/issues/65)
* Minor changes to improve support for Ruby 1.9.3 tests

v.3.1.1 (2014-08-14)
--------------------

####Fixes
Resolves [#59](https://github.com/datasift/datasift-ruby/issues/59); we now use CGI.escape rather than URI.escape to ensure special characters such as '+' or '\' are escaped correctly when submitted.

v.3.1.0 (2014-07-30)
--------------------

####New Feature
Added support for four new Managed Sources API endpoints to improve usability of the Managed Sources API, and make it easier to add or remove resources or authentication tokens
* /source/auth/add
* /source/auth/remove
* /source/resource/add
* /source/resource/remove

####Improvements
Ensure all POST and PUT API requests are sent JSON encoded with correct headers

v.3.0.1 (2014-07-17)
--------------------

Ensure we use TLSv1 when using SSL

v.3.0.0 (2014-07-04)
--------------------

Final fixes for v.3.0.0!
This release does break backwards compatibility with version 2.x and earlier. A [migration guide](MIGRATING_TO_V.3.0.0.md) is available.
* Adds support for the [Pull Push Destination](http://dev.datasift.com/docs/products/stream/features/delivery/push/push-connectors/pull)
* Adds support for DataSift [Historics Preview](http://dev.datasift.com/docs/products/stream/features/historics/preview)
* Adds support for the new Dynamic Lists feature
* Adds support for multi-streaming via WebSockets
* Added a CLI to the library
* Updated test suite

v.3.0.0.beta (2013-11-07)
-------------------------

Total rewrite of the DataSift client library for Ruby.

This release does break backwards compatibility with previous versions. New features include:
* Support for DataSift Historics Preview
* Support for multi-streaming via WebSockets

v.2.1.0 (2013-09-13)
--------------------

Final fixes for v.2.1.0

* Adds /source/log call
* Updated /source/create call to comply with latest version of the API
* Removed JSON gem - now dependant on Yajl-Ruby for JSON parsing
* Added license info to gemspec
* Fixed edge case when passing refresh token to authentication with G+ API
* Fixed /source/get call

v.2.1.0.beta (2013-08-05)
-------------------------

Adding Managed Sources support.
Thanks to [giovannelli](https://github.com/giovannelli) for the contribution

v.2.0.4 (2013-03-18)
--------------------

Bug fix to handle HTTP 202 response codes

v.2.0.3 (2013-03-04)
--------------------

Stability improvement and bug fix

* Removed references to deprecated Historic output field 'volume_info'.
* Added 65s timeout on live streaming to handle 'silent' server disconnects.
* Minor changes to ensure Ruby 2.0 compatibility.

v.2.0.2 (2012-12-03)
--------------------

Added missing Historic sample size into historic/prepare requests

v.2.0.1 (2012-09-03)
--------------------

Fixed a bug that was preventing streaming connections from being established

v.2.0.0 (2012-08-31)
--------------------

Added support for Historics queries and Push delivery

v.1.5.0 (2012-05-24)
--------------------

Added getBalance to the User class [joncooper](https://github.com/joncooper)

v.1.4.1 (2012-05-15)
--------------------

Fixed a minor bug in the SSL support

v.1.4.0 (2012-05-15)
--------------------

Added SSL support

This is enabled by default and can be disabled by passing false as the third
parameter to the User constructor, or calling enableSSL(false) on the User
object.

v.1.3.1 (2012-04-20)
--------------------

Exposed compile failures when getting the stream hash

v.1.3.0 (2012-03-08)
--------------------

Improved error handling

* Added onError and onWarning events - see examples/consume-stream.rb for an example.
* Stopped the HTTP consumer from attempting to reconnect when it receives a 4xx response from the server.

v.1.2.0 (2012-02-28)
--------------------

Twitter Compliance

* The consumer now has an onDeleted method to which you can assign a block that will be called to handle DELETE requests from Twitter. See delete.rb in the examples folder for a sample implementation. (@see http://dev.datasift.com/docs/products/stream/features/sources/public-sources/twitter/twitter-delete-messages)

NB: if you are storing tweets you must implement this method in your code
and take appropriate action to maintain compliance with the Twitter license.
