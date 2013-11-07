DataSift
========

The official Ruby library for accessing the DataSift API. See
http://datasift.com/ for full details and to sign up for an account.

Install Instructions
--------------------

sudo gem install datasift

Dependencies
------------

If you're using the source you'll need to install the dependencies.

sudo gem install rest-client multi_json websocket-td

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

License
-------

All code contained in this repository is Copyright 2011-2013 MediaSift Ltd.

This code is released under the BSD license. Please see the LICENSE file for
more details.
