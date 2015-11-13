require './auth'
class AccountIdentityEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      puts "Create a new identity"
      identity = @datasift.account_identity.create(
        "Ruby Identity #{DateTime.now}", "active", false
      )
      identity_id = identity[:data][:id]
      puts identity[:data].to_json

      puts "\nList all existing identities"
      puts @datasift.account_identity.list[:data].to_json

      puts "\nGet existing identity"
      puts @datasift.account_identity.get(identity_id)[:data].to_json

      puts "\nUpdate an identity"
      puts @datasift.account_identity.update(
        identity_id, "Updated Ruby Identity #{DateTime.now}"
      )[:data].to_json

      puts "\nDelete an identity"
      @datasift.account_identity.delete(identity_id)

    rescue DataSiftError => dse
      puts dse.inspect
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
      puts "\nClean up and delete the identity"
      @datasift.account_identity.delete(identity_id)
    end
  end
end

AccountIdentityEg.new
