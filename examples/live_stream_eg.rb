require './auth'
class StreamingApi < DataSiftExample

  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      ruby_received   = 0
      python_received = 0
      ruby           = 'interaction.content contains "ruby"'
      ruby_stream     = @datasift.compile ruby

      python       = 'interaction.content contains "python"'
      python_stream = @datasift.compile python

      on_delete = lambda { |stream, m| puts 'We must delete this to be compliant ==> ' + m }

      on_error = lambda do |stream, e|
        puts 'A serious error has occurred'
        puts e.message
      end

      on_message_ruby = lambda do |message, stream, hash|
        ruby_received += 1
        puts "Ruby #{ruby_received}, #{message}"

        if ruby_received >= 10
          puts 'un-subscribing from ruby stream '+ hash
          stream.unsubscribe hash
        end
      end

      on_message_python = lambda do |message, stream, hash|
        python_received += 1
        puts "python #{python_received}, #{message}"

        if python_received >= 10
          puts 'un-subscribing from python stream '+ hash
          stream.unsubscribe hash
        end
      end

      on_connect = lambda do |stream|
        #
        puts 'subscribing to python stream '+ python_stream[:data][:hash]
        stream.subscribe(python_stream[:data][:hash], on_message_python)
        puts 'Subscribed to '+ python_stream[:data][:hash]
        sleep 1
        #
        puts 'subscribing to ruby stream '+ ruby_stream[:data][:hash]
        stream.subscribe(ruby_stream[:data][:hash], on_message_ruby)
        puts 'Subscribed to '+ ruby_stream[:data][:hash]
      end

      on_close = lambda do |stream,msg|
        puts msg
      end

      on_datasift_message = lambda do |stream, message, hash|
        #not all messages have a hash
        puts "is_success =  #{message[:is_success]}, is_failure =  #{message[:is_failure]}, is_warning =  #{message[:is_warning]}, is_tick =  #{message[:is_tick]}"
        puts "DataSift Message #{hash} ==> #{message}"
      end

      conn                     = DataSift::new_stream(@config, on_delete, on_error, on_connect, on_close)
      conn.on_datasift_message = on_datasift_message
      #can do something else here now...
      puts 'Do some other business stuff...'
      conn.stream.read_thread.join
        #rescue DataSiftError
    rescue DataSiftError => dse
      puts "Error #{dse.message}"
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