module DataSift
  # Methods for using Auth specific Managed Sources API endpoints
  class ManagedSourceAuth < DataSift::ApiResource
    # Add auth tokens to a Managed Source
    #
    # @param id [String] ID of the Managed Source you are adding Auth tokens to
    # @param auth [Array] Array of auth tokens you are adding to your source
    # @param validate [Boolean] Whether you want to validate your new tokens
    #   against the third party API (i.e. the Facebook or Instagram API)
    def add(id, auth, validate = 'true')
      params = {
        id: id,
        auth: auth,
        validate: validate
      }
      requires params
      DataSift.request(:PUT, 'source/auth/add', @config, params)
    end

    # Remove auth tokens from a Managed Source
    #
    # @param id [String] ID of the Managed Source you are removing auth tokens
    #   from
    # @param auth_ids [Array] Array of auth_id strings you need to remove from
    #   your source
    def remove(id, auth_ids)
      params = {
        id: id,
        auth_ids: auth_ids
      }
      requires params
      DataSift.request(:PUT, 'source/auth/remove', @config, params)
    end
  end
end
