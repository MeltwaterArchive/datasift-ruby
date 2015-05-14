module DataSift
  #
  # Class for accessing DataSift's Account API Identities
  class AccountIdentity < DataSift::ApiResource
    # Creates a new Identity
    #
    # @param label [String] A unique identifier for this Identity
    # @param status [String] (Optional, Default: "active") What status this
    #   Identity currently has. Possible values are 'active' and 'disabled'
    # @param master [Boolean] (Optional, Default: false) Whether this is the
    #   master Identity for your account
    # @return [Object] API reponse object
    def create(label = '', status = 'active', master = '')
      fail ArgumentError, 'label is missing' if label.empty?

      params = { label: label }
      params.merge!(status: status) unless status.empty?
      params.merge!(master: master) if [TrueClass, FalseClass].include?(master.class)

      DataSift.request(:POST, 'account/identity', @config, params)
    end

    # Gets a specific Identity by ID
    #
    # @param id [String] ID of the Identity you wish to return
    # @return [Object] API reponse object
    def get(id)
      DataSift.request(:GET, "account/identity/#{id}", @config)
    end

    # Returns a list of Identities
    #
    # @param label [String] (Optional) Search by a given Identity label
    # @param per_page [Integer] (Optional) How many Identities should be
    #   returned per page of results
    # @param page [Integer] (Optional) Which page of results to return
    # @return [Object] API reponse object
    def list(label = '', per_page = '', page = '')
      params = {}
      params.merge!(label: label) unless label.empty?
      params.merge!(per_page: per_page) unless per_page.empty?
      params.merge!(page: page) unless page.empty?

      DataSift.request(:GET, 'account/identity', @config, params)
    end

    # Updates a specific Identity by ID
    #
    # @param id [String] ID of the Identity you are updating
    # @param label [String] (Optional) New label value
    # @param status [String] (Optional) New status for this Identity
    # @param master [Boolean] (Optional) Whether this Identity should be master
    # @return [Object] API reponse object
    def update(id = '', label = '', status = '', master = '')
      fail ArgumentError, 'id is missing' if id.empty?

      params = {}
      params.merge!(label: label) unless label.empty?
      params.merge!(status: status) unless status.empty?
      params.merge!(master: master) if [TrueClass, FalseClass].include?(master.class)

      DataSift.request(:PUT, "account/identity/#{id}", @config, params)
    end

    # Deletes a specific Identity by ID
    #
    # @param id [String] ID of the Identity you wish to delete
    # @return [Object] API response object
    def delete(id)
      DataSift.request(:DELETE, "account/identity/#{id}", @config)
    end
  end
end
