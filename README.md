DataSift
========
[![Gem Version](http://img.shields.io/gem/v/datasift.svg)][gem]
[![Build Status](http://img.shields.io/travis/datasift/datasift-ruby.svg)][travis]

[gem]: https://rubygems.org/gems/datasift
[travis]: https://travis-ci.org/datasift/datasift-ruby


The official Ruby library for accessing the DataSift API.

Getting Started
---------------
**Read our [Stream](http://dev.datasift.com/docs/products/stream/quick-start/getting-started-ruby) and [PYLON](http://dev.datasift.com/docs/products/pylon-fbtd/get-started/getting-started-ruby) Getting Started guides for an introduction to the DataSift platform.** The guides will take you through creating a [DataSift](https://datasift.com) account, and activating data sources which you will need to do before using the DataSift API.

Many of the examples and API endpoints used in this library require you have enabled certain data sources before you can receive any data (you should do this at [https://datasift.com/source](https://datasift.com/source)). Certain API features, such as [Historics](https://datasift.com/platform/historics/) and [Managed Sources](https://datasift.com/platform/datasources/) will require you have signed up to a monthly subscription before you can access them.

If you are interested in using these features, or would like more information about DataSift, please [get in touch](https://datasift.com/contact-us/)!


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
you may disable it if required by passing ```enable_ssl: false``` as the third
parameter when creating your ```@config``` object.


Simple example
--------------
This example looks for anything that contains the word "football" in real-time,
and simply prints the content to the screen as they come in.

```ruby
require 'datasift'
@config = { username: 'DATASIFT_USERNAME', api_key: 'DATASIFT_API_KEY' }
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

Supported Operating Environment
-------------------------------
This version of the client library has been tested, and is known to work against the following language versions and Operating Systems:

### Language Versions
* Ruby 1.9.3 (May work, but no longer officially supported)
* Ruby 2.0 (May work, but no longer officially supported)
* Ruby 2.1 (May work, but no longer officially supported)
* Ruby 2.2
* Ruby 2.3
* Ruby 2.4
* Ruby 2.5

### Operating Systems
* Linux
* Ubuntu
* OS X
* Windows 7/8

Contributing
------------
Contributions are always welcome and appreciated

1. Fork on GitHub
2. Create a feature branch (we use [Gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) for branching)
3. Commit your changes with tests. Please try not to break backwards-compatibility :)

Testing
-------
When contributing new code, it should be accompanied with appropriate tests.
When adding new tests, or testing a new API version, you should follow these steps:
1. Add your credentials and appropriate API version to the `examples/auth.rb` file (these credentials will not be stored anywhere. Please remember to remove them before committing code!)
2. Run `bundle install; rake build; rake install` to ensure we are using the latest versions of your changes
3. Run `rake test` to run the full test suite, or you can run `ruby test/datasift/<test_file>` to run just a specific test.
4. When you have successfully tested your changes, and stored the API response from any new API calls using VCR (see the `test/fixtures/cassettes` directory), run `rake test` again to run the full test suite. If that passes, you should be good to commit and push your changes.

License
-------
This code is released under the BSD license. Please see the [LICENSE](LICENSE) file for details.
