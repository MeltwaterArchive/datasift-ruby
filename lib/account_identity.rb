module DataSift
  #
  # Class for accessing DataSift's Account API Identities
  class AccountIdentity < DataSift::ApiResource
    PATH = 'account/identity'

    # Creates a new Identity
    #
    # @param label [String] A unique identifier for this Identity
    # @param status [String] (Optional, Default: "active") What status this
    #   Identity currently has. Possible values are 'active' and 'disabled'
    # @param master [Boolean] (Optional, Default: false) Whether this is the 
    #   master Identity for your account
    # @return [Object] API reponse object
    def create(label, status: 'active', master: false)
      params = { 
        label: label,
        status: status,
        master: master
      }
      requires params
      DataSift.request(:POST, 'account/identity', @config, params)
    end

    # Gets a specific Identity by ID
    #
    # @param id [String] ID of the Identity you wish to return
    # @return [Object] API reponse object
    def read(id)
      requires { id: id }
      DataSift.request(:GET, "account/identity/#{id}", @config)
    end

    # Returns a list of Identities
    #
    # @param label [String] 
    # @param per_page [Integer] 
    # @param page [Integer] 
    # @return [Object] API reponse object
    def list(label: '', per_page: '', page: '')
      puts '------------path'
      puts PATH
      params = {}
      params.merge!(label: label) unless label.empty?
      params.merge!(per_page: per_page) unless per_page.empty?
      params.merge!(page: page) unless page.empty?
      DataSift.request(:GET, 'account/identity', @config, params)
    end

    # Updates a specific Identity by ID
    #
    # @param  
    # @return [Object] API reponse object
    def update(id, label: '', status: '', master: '')
      params = {}
      params.merge!(label: label) unless label.empty?


      
      DataSift.request(:PUT, "account/identity/#{id}", @config, params)
    end

    # Deletes a specific Identity by ID
    #
    # @param id [String] ID of the Identity you wish to delete
    # @return []
    def delete(id)
      params = { id: id }
      requires params
      DataSift.request(:DELETE, "account/identity/#{id}", @config, params)
    end

    end
  end
end
