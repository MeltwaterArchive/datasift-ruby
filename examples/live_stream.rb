require './auth'
class StreamingApi < DataSiftExample

  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      csdl = 'interaction.content contains "test"'

      stream = @datasift.compile csdl
      puts 'subscribing to '+stream[:data][:hash]

      @datasift.stream.on_delete = lambda { |m| puts 'We must delete this to be compliant ==> ' + m }

      @datasift.stream.on_error = lambda do |e|
        puts 'A serious error has occurred'
        puts e.message
      end

      @datasift.stream.subscribe stream
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