module DataSift
  #
  # Class for accessing DataSift's Account API Identity Tokens
  class AccountIdentityToken < DataSift::ApiResource
    # Creates a new Identity Token
    #
    # @param identity_id [String] ID of the Identity for which you are creating
    #   a token
    # @param service [String] The service this token will be used to access. For
    #   example; 'facebook'
    # @param token [String] The token provided by the PYLON data provider
    # @return [Object] API reponse object
    def create(identity_id: '', service: '', token: '')
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?
      fail BadParametersError, 'token is required' if token.empty?
      params = {
        service: service,
        token: token
      }

      DataSift.request(:POST, "account/identity/#{identity_id}/token", @config, params)
    end

    # Get a Token for a given Identity and Service
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

    # Returns a list of Tokens for a given Identity
    #
    # @param identity_id [String] ID of the Identity we are fetching Tokens for
    # @param per_page [Integer] (Optional) How many Tokens should be returned
    #   per page of results
    # @param page [Integer] (Optional) Which page of results to return
    # @return [Object] API reponse object
    def list(identity_id: '', per_page: '', page: '')
      params = { identity_id: identity_id }
      requires params
      params.merge!(per_page: per_page) unless per_page.empty?
      params.merge!(page: page) unless page.empty?

      DataSift.request(:GET, "account/identity/#{identity_id}/token", @config, params)
    end

    # Updates a specific Token by Identity ID and Service
    #
    # @param identity_id [String] ID of the Identity you are updating a token
    #   for
    # @param service [String] The service this token will be used to access. For
    #   example; 'facebook'
    # @param token [String] The token provided by the PYLON data provider
    # @return [Object] API reponse object
    def update(identity_id: '', service: '', token: '')
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?
      fail BadParametersError, 'token is required' if token.empty?
      params = {
        token: token
      }

      DataSift.request(:PUT, "account/identity/#{identity_id}/token/#{service}", @config, params)
    end

    # Deletes a specific Token by Identity and Service
    #
    # @param identity_id [String] ID of the Identity for which you wish to
    #   delete a token
    # @param service [String] Service from which you wish to delete a token
    # @return [Object] API response object
    def delete(identity_id: '', service: '')
      fail BadParametersError, 'identity_id is required' if identity_id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      DataSift.request(:DELETE, "account/identity/#{identity_id}/token/#{service}", @config)
    end
  end
end
