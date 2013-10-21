require './auth'
class StreamingApi < DataSiftExample

  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      rubyReceived   = 0
      coffeeReceived = 0
      ruby           = 'interaction.content contains "ruby"'
      rubyStream     = @datasift.compile ruby

      coffee       = 'interaction.content contains "coffee"'
      coffeeStream = @datasift.compile coffee

      on_delete = lambda { |stream, m| puts 'We must delete this to be compliant ==> ' + m }

      on_error = lambda do |stream, e|
        puts 'A serious error has occurred'
        puts e.message
      end

      on_message_ruby = lambda do |message, stream, hash|
        rubyReceived += 1
        puts "Ruby #{rubyReceived}, #{message}"

        if rubyReceived >= 10
          puts 'un-subscribing from ruby stream '+ hash
          stream.unsubscribe hash
        end
      end

      on_message_coffee = lambda do |message, stream, hash|
        coffeeReceived += 1
        puts "Coffee #{coffeeReceived}, #{message}"

        if coffeeReceived >= 10
          puts 'un-subscribing from coffee stream '+ hash
          stream.unsubscribe hash
        end
      end

      on_connect = lambda do |stream|
        #
        puts 'subscribing to coffee stream '+ coffeeStream[:data][:hash]
        stream.subscribe(coffeeStream[:data][:hash], on_message_coffee)
        puts 'Subscribed to '+ coffeeStream[:data][:hash]
        #
        puts 'subscribing to ruby stream '+ rubyStream[:data][:hash]
        stream.subscribe(rubyStream[:data][:hash], on_message_ruby)
        puts 'Subscribed to '+ rubyStream[:data][:hash]
      end

      on_close = lambda do |stream|
        puts 'closed'
      end

      on_datasift_message = lambda do |stream, message, hash|
        #not all messages have a hash
        puts "is_success =  #{message[:is_success]}, is_failure =  #{message[:is_failure]}, is_warning =  #{message[:is_warning]}, is_tick =  #{message[:is_tick]}"
        puts "DataSift Message #{hash} ==> #{message}"
      end

      EM.run do
        stream                     = DataSift::new_stream(@config, on_delete, on_error, on_connect, on_close)
        stream.on_datasift_message = on_datasift_message
        #can do something else here now...
        puts 'Do some other business stuff...'
      end

        #rescue DataSiftError
    rescue DataSiftError => dse
      puts dse.message
      # Then match specific one to take action - All errors thrown by the client extend DataSiftError
      case dse
        when ConnectionError
          # some connection error
        when AuthError
        when BadRequestError
        else
          # do something else...
      end
    end
  end
end
StreamingApi.new