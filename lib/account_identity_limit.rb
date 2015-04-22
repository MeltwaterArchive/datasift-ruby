module DataSift
  #
  # Class for accessing DataSift's Account API Identity Limits
  class AccountIdentityLimit < DataSift::ApiResource
    # Creates a Limit for an Identity
    #
    # @param identity_id [String] ID of the Identity for which you are creating
    #   a limit
    # @param service [String] The service this limit will apply to. For example;
    #   'facebook'
    # @param total_allowance [Integer] The limit for this Identity
    # @return [Object] API reponse object
    def create(identity_id: '', service: '', total_allowance: nil)
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?
      fail BadParametersError, 'total_allowance can not be "nil"' if total_allowance.nil?
      params = {
        service: service,
        total_allowance: total_allowance
      }

      DataSift.request(:POST, "account/identity/#{identity_id}/limit", @config, params)
    end

    # Get the Limit for a given Identity and Service
    #
    # @param identity_id [String] ID of the Identity you wish to return tokens
    #   for
    # @param service [String] Name of the service you are retreiving tokens for
    # @return [Object] API reponse object
    def get(identity_id: '', service: '')
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      DataSift.request(:GET, "account/identity/#{identity_id}/token/#{service}", @config)
    end

    # Returns a list Identities and their Limits for a given Service
    #
    # @param service [String] ID of the Identity we are fetching Tokens for
    # @param per_page [Integer] (Optional) How many Identities and Limits should
    #   be returned per page of results
    # @param page [Integer] (Optional) Which page of results to return
    # @return [Object] API reponse object
    def list(service: '', per_page: '', page: '')
      fail BadParametersError, 'service is required' if service.empty?
      params.merge!(per_page: per_page) unless per_page.empty?
      params.merge!(page: page) unless page.empty?

      DataSift.request(:GET, "account/identity/limit/#{service}", @config, params)
    end

    # Updates a Limit for an Identity by Service
    #
    # @param identity_id [String] ID of the Identity for which you are updating
    #   a limit
    # @param service [String] The service this limit will apply to. For example;
    #   'facebook'
    # @param total_allowance [Integer] The new limit for this Identity
    # @return [Object] API reponse object
    def update(identity_id: '', service: '', total_allowance: nil)
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?
      fail BadParametersError, 'total_allowance can not be "nil"' if total_allowance.nil?
      params = { total_allowance: total_allowance }

      DataSift.request(:PUT, "account/identity/#{identity_id}/limit/#{service}", @config, params)
    end

    # Removes a Service Limit for an Identity
    #
    # @param identity_id [String] ID of the Identity for which you wish to
    #   remove the Limit
    # @param service [String] Service from which you wish to remove the Limit
    # @return [Object] API response object
    def delete(identity_id: '', service: '')
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      DataSift.request(:DELETE, "account/identity/#{identity_id}/limit/#{service}", @config, params)
    end
  end
end
