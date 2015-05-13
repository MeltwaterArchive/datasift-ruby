require './auth'
class AccountIdentityLimitEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      puts "Create a new identity to apply Limits to"
      identity = @datasift.account_identity.create(
        "Ruby Identity for Token Limits", "active", false
      )
      identity_id = identity[:data][:id]
      puts identity.to_json

      puts "\nCreate a Limit for our Identity"
      puts @datasift.account_identity_limit.create(
        identity_id,
        'facebook',
        100_000
      )

      puts "\nList all existing Limits for this Service"
      puts @datasift.account_identity_limit.list(
        'facebook'
      ).to_json

      puts "\nGet existing Limit by Identity and Service"
      puts @datasift.account_identity_limit.list(
        identity_id,
        'facebook'
      ).to_json

      puts "\nUpdate a Limit for a given Identity"
      puts @datasift.account_identity_limit.update(
        identity_id,
        'facebook',
        250_000
      ).to_json

      puts "\nRemove the Limit from a given Identity and Service"
      puts @datasift.account_identity_limit.delete(
        identity_id,
        'facebook'
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

AccountIdentityLimitEg.new
