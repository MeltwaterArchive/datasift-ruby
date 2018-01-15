require './auth'
require 'date'

class AccountEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      start_time = DateTime.strptime('01/12/2017', '%d/%m/%Y').to_time.to_i
      end_time = DateTime.strptime('01/01/2018', '%d/%m/%Y').to_time.to_i

      puts "Get account usage for the default period"
      puts @datasift.account.usage(start_time, end_time)[:data].to_json

      puts "\nGet account usage for the past month"
      puts @datasift.account.usage(start_time, end_time, 'monthly')[:data].to_json

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
