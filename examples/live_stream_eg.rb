require './auth'
class StreamingApi < DataSiftExample

  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      csdl = 'interaction.content contains "php"'

      stream = @datasift.compile csdl

      on_delete = lambda { |m| puts 'We must delete this to be compliant ==> ' + m }

      on_error = lambda do |e|
        puts 'A serious error has occurred'
        puts e.message
      end

      on_connect = lambda do
        puts 'subscribing to '+ stream[:data][:hash]
        @datasift.stream.subscribe stream
      end
      #em_thread  = Thread.new do
      EM.run do
        @datasift.stream.connect(on_connect, on_delete, on_error)
      end
        #end
        #while !@datasift.stream.connected?
        #  sleep 1
        #end
        #em_thread.join
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