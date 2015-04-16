require './auth'
class AccountIdentityEg < DataSiftExample
  def initialize
    super


    @config.merge!(
      api_host: 'api.fido.dpr-229.devms.net',
      username: 'choult',
      api_key: 'eed85f6b316fb18930ee28e8754f4963',
      enable_ssl: true
    )
    
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
#      puts "Create a new identity"
#      identity = @datasift.account_identity.create(
#        label: "Ruby Identity", status: "active", master: false
#      )
#      puts identity.to_json
#      
#      puts "\nList all existing identities"
#      puts @datasift.account_identity.list.to_json
#
#      puts "\nGet existing identity"
#      puts @datasift.account_identity.get(identity[:data][:id]).to_json
#
#      puts "\nUpdate an identity"
#      puts @datasift.account_identity.update(identity[:data][:id], label: 'new', status: 'active').to_json
#
#      puts "\nDelete an identity"
#      puts @datasift.account_identity.delete(identity[:data][:id]).to_json

      puts @datasift.account_identity.update("identity", label: 'new', status: 'active').to_json

    #rescue DataSiftError
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

AccountIdentityEg.new
