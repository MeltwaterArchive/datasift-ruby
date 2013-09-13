DataSift
========

The official Ruby library for accessing the DataSift API. See
http://datasift.com/ for full details and to sign up for an account.

The examples use the username and API key in config.yml unless otherwise noted.

Install Instructions
--------------------

sudo gem install datasift

Dependencies
------------

If you're using the source you'll need to install the dependencies.

sudo gem install yajl-ruby rest-client

The library will use SSL connections by default. While we recommend using SSL
you may disable it if required by passing false as the third parameter when
creating a user, or by calling user.enableSSL(false) on the user object.

Simple example
--------------

This example looks for anything that contains the word "datasift" and simply
prints the content to the screen as they come in.

```ruby
require 'rubygems'
require 'datasift'
user = DataSift::User.new("your username", "your api_key")
definition = user.createDefinition('interaction.content contains "football"')
consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
consumer.consume(true) do |interaction|
	if interaction
		puts interaction['interaction']['content']
	end
end
```

See the DataSift documentation for full details of the data contained within
each interaction. See this page on our developer site for an example tweet:
http://dev.datasift.com/docs/targets/twitter/tweet-output-format

License
-------

All code contained in this repository is Copyright 2011-2013 MediaSift Ltd.

This code is released under the BSD license. Please see the LICENSE file for
more details.

Changelog
---------
* v.2.1.0 Final fixes for v.2.1.0  (2013-09-13)

  - Adds /source/log call
  - Updated /source/create call to comply with latest version of the API
  - Removed JSON gem - now dependant on Yajl-Ruby for JSON parsing
  - Added license info to gemspec
  - Fixed edge case when passing refresh token to authentication with G+ API
  - Fixed /source/get call

* v.2.1.0.beta Adding Managed Sources support. Thanks to [giovannelli](https://github.com/giovannelli) for the contribution (2013-08-05)

* v.2.0.4 Bug fix to handle HTTP 202 response codes (2013-03-18)

* v.2.0.3 Stability improvement and bug fix (2013-03-04)

  Removed references to deprecated Historic output field 'volume_info'.
  Added 65s timeout on live streaming to handle 'silent' server disconnects.
  Minor changes to ensure Ruby 2.0 compatibility.

* v.2.0.2 Added missing Historic sample size into historic/prepare requests (2012-12-03)

* v.2.0.1 Fixed a bug that was preventing streaming connections from being established (2012-09-03)

* v.2.0.0 Added support for Historics queries and Push delivery (2012-08-31)

* v.1.5.0 Added getBalance to the User class [joncooper](https://github.com/joncooper) (2012-05-24)

* v.1.4.1 Fixed a minor bug in the SSL support (2012-05-15)

* v.1.4.0 Added SSL support (2012-05-15)

  - This is enabled by default and can be disabled by passing false as the third
  parameter to the User constructor, or calling enableSSL(false) on the User
  object.

* v.1.3.1 Exposed compile failures when getting the stream hash (2012-04-20)

* v.1.3.0 Improved error handling (2012-03-08)

  - Added onError and onWarning events - see examples/consume-stream.rb for an
  example.

  - Stopped the HTTP consumer from attempting to reconnect when it receives a
  4xx response from the server.

* v.1.2.0 Twitter Compliance (2012-02-28)

  - The consumer now has an onDeleted method to which you can assign a block
  that will be called to handle DELETE requests from Twitter. See delete.rb
  in the examples folder for a sample implementation.
  (@see http://dev.datasift.com/docs/twitter-deletes)

  - NB: if you are storing tweets you must implement this method in your code
  and take appropriate action to maintain compliance with the Twitter license.
