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
      puts "Is the following CSDL valid? #{csdl}"
      puts @datasift.valid? csdl

      # http://dev.datasift.com/docs/rest-api/compile
      puts "\nCompile the CSDL and get a stream hash"
      stream = @datasift.compile csdl
      puts stream[:data]

      # http://dev.datasift.com/docs/rest-api/dpu
      puts "\nGet the DPU cost of the compiled CSDL"
      dpu = @datasift.dpu stream[:data][:hash]
      puts dpu[:data][:dpu]

      # http://dev.datasift.com/docs/rest-api/balance
      puts "\nGet the remaining balance for my account"
      balance = @datasift.balance
      puts balance[:data]

      #http://dev.datasift.com/docs/rest-api/usage
      puts "\nGet my recent account usage"
      usage = @datasift.usage
      puts usage[:data]

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
