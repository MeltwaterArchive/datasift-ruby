DataSift
========

[![Gem Version](http://img.shields.io/gem/v/datasift.svg)][gem]
[![Build Status](http://img.shields.io/travis/datasift/datasift-ruby.svg)][travis]

[gem]: https://rubygems.org/gems/datasift
[travis]: https://travis-ci.org/datasift/datasift-ruby


The official Ruby library for accessing the DataSift API.

Getting Started
---------------

**Read our [Ruby Getting Started Guide](http://dev.datasift.com/quickstart/ruby) to get started with the DataSift platform.** The guide will take you through creating a [DataSift](http://datasift.com) account, and activating data sources which you will need to do before using the DataSift API.

Many of the examples and API endpoints used in this library require you have enabled certain data sources before you can receive any data (you should do this at [datasift.com/source](https://datasift.com/source)). Certain API features, such as [Historics](http://datasift.com/platform/historics/) and [Managed Sources](http://datasift.com/platform/datasources/) will require you have signed up to a monthly subscription before you can access them.

If you are interested in using these features, or would like more information about DataSift, please [get in touch](http://datasift.com/contact-us/)!


Install Instructions
--------------------

```
sudo gem install datasift
```

Dependencies
------------

If you're using the source you'll need to install the dependencies.

```
sudo gem install rest-client multi_json websocket-td
```

The library will use SSL connections by default. While we recommend using SSL
you may disable it if required by passing ':enable_ssl => false' as the third
parameter when creating your @config object.


Simple example
--------------

This example looks for anything that contains the word "football" in real-time,
and simply prints the content to the screen as they come in.

```ruby
require 'datasift'
@config = {:username => 'DATASIFT_USERNAME', :api_key => 'DATASIFT_API_KEY', :enable_ssl => true}
@datasift = DataSift::Client.new(@config)
csdl = 'interaction.content contains "football"'
filter = @datasift.compile csdl
receivedCount = 0

on_delete = lambda { |stream, m| puts 'We must delete this to be compliant ==> ' + m }
on_error = lambda { |stream, e| puts "A serious error has occurred: #{e.message}" }
on_message = lambda do |message, stream, hash|
  receivedCount += 1
  puts "Received interaction: #{message}"

  if receivedCount >= 5
    puts "Unsubscribing from hash #{hash}"
    stream.unsubscribe hash
  end
end

on_connect = lambda do |stream|
  stream.subscribe(filter[:data][:hash], on_message)
  puts 'Subscribed to '+ filter[:data][:hash]
end

on_datasift_message = lambda do |stream, message, hash|
  #not all messages have a hash
  puts "is_success =  #{message[:is_success]}, is_failure =  #{message[:is_failure]}, is_warning =  #{message[:is_warning]}, is_tick =  #{message[:is_tick]}"
  puts "DataSift Message #{hash} ==> #{message}"
end

conn = DataSift::new_stream(@config, on_delete, on_error, on_connect)
conn.on_datasift_message = on_datasift_message
conn.stream.read_thread.join
```

See the [Understanding the Output Data](http://dev.datasift.com/docs/getting-started/data) page on the DataSift Developer site for
full details of the data contained within each interaction.

Supported Operating Environment
-------------------------------
This version of the client library has been tested, and is known to work against the following language versions and Operating Systems:

### Language Versions
* Ruby 1.9.3 (Seems to work, but NOT officially supported/thoroughly tested)
* Ruby 2.0.0
* Ruby 2.1
* Ruby 2.2

### Operating Systems
* Linux
* Ubuntu
* OS X
* Windows 7/8

License
-------

All code contained in this repository is Copyright 2011-2015 MediaSift Ltd.

This code is released under the BSD license. Please see the [LICENSE](https://github.com/datasift/datasift-ruby/blob/master/LICENSE) file for
more details.
