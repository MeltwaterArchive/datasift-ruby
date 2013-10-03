require './auth'
class CoreApiEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      csdl = 'interaction.content contains "test"'
      # see docs at http://dev.datasift.com/docs/rest-api/validate
      puts @datasift.valid? csdl

      # http://dev.datasift.com/docs/rest-api/compile
      stream = @datasift.compile csdl
      puts stream[:data][:hash]

      # http://dev.datasift.com/docs/rest-api/dpu
      puts @datasift.dpu stream[:data][:hash]

      # http://dev.datasift.com/docs/rest-api/balance
      puts @datasift.balance

      #http://dev.datasift.com/docs/rest-api/usage
      puts @datasift.usage

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
CoreApiEg.new