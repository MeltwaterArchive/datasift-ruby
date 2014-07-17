CHANGELOG
================================

v.3.0.1 (2014-07-17)
--------------------

Ensure we use TLSv1 when using SSL

v.3.0.0 (2014-07-04)
--------------------

Final fixes for v.3.0.0!
This release does break backwards compatibility with version 2.x and earlier. A [migration guide](https://github.com/datasift/datasift-ruby/blob/3.0.0/MIGRATING_TO_V.3.0.0.md) is available.
* Adds support for the [Pull Push Destination](http://dev.datasift.com/docs/push/connectors/pull)
* Adds support for DataSift [Historics Preview](http://dev.datasift.com/docs/historics/preview)
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

* The consumer now has an onDeleted method to which you can assign a block that will be called to handle DELETE requests from Twitter. See delete.rb in the examples folder for a sample implementation. (@see http://dev.datasift.com/docs/twitter-deletes)

NB: if you are storing tweets you must implement this method in your code
and take appropriate action to maintain compliance with the Twitter license.
