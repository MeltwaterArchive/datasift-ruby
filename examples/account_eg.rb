require './auth'
class AccountEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      puts "Get account usage for the default period"
      puts @datasift.account.usage[:data].to_json

      puts "\nGet account usage for the past month"
      puts @datasift.account.usage('monthly')[:data].to_json

    rescue DataSiftError => dse
      puts dse.message
      # Then match specific error to take action;
      #   All errors thrown by the client extend DataSiftError
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

AccountEg.new
