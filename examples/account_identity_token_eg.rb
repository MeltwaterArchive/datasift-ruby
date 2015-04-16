require './auth'
class AccountIdentityTokenEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      puts "Create a new identity"
      identity = @datasift.account_identity.create(
        label: "Ruby Identity for Tokens", status: "active", master: false
      )
      identity_id = identity[:data][:id]
      puts identity.to_json

      puts "\nCreate a Token for our Identity"
      puts @datasift.account_identity_token.create(
        identity_id: identity_id, 
        service: 'facebook', 
        token: 'YOUR_TOKEN'
      )
      
      puts "\nList all existing tokens for this Identity"
      puts @datasift.account_identity_token.list(
        identity_id: identity_id
      ).to_json

      puts "\nGet existing Token by Identity and Service"
      puts @datasift.account_identity_token.list(
        identity_id: identity_id, 
        service: 'facebook'
      ).to_json

      puts "\nUpdate a Token for a given Identity"
      puts @datasift.account_identity_token.update(
        identity_id: identity_id, 
        token: 'YOUR_NEW_TOKEN'
      ).to_json

      puts "\nDelete an Token for a given Identity and Service"
      puts @datasift.account_identity_token.delete(
        identity_id: identity_id,
        service: 'facebook'
      ).to_json

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

AccountIdentityTokenEg.new
