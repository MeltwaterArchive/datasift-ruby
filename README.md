DataSift
========

The official Ruby library for accessing the DataSift API. See http://datasift.net for full details and to sign up for an account.

The examples and tests use the username and API key in config.yml.

Install Instructions
--------------------

sudo gem install datasift

Dependencies
------------

sudo gem install yajl-ruby

Simple example
--------------

This example looks for anything that contains the word "datasift" and simply prints the content to the screen as they come in.

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

See the DataSift documentation for full details of the data contained within each interaction. See this page on our developer site for an example tweet: http://dev.datasift.com/docs/targets/twitter/twitter-output-format

License
-------

All code contained in this repository is Copyright 2011-2012 MediaSift Ltd.

This code is released under the BSD license. Please see the LICENSE file for more details.
