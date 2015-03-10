module DataSift
  # Methods for using {http://dev.datasift.com/docs/sources/managed-sources
  #   DataSift Managed Sources}
  class ManagedSource < DataSift::ApiResource
    # Creates a new managed source
    #
    # @param source_type [String] Type of Managed Source you are creating. e.g.
    #   facebook_page, instagram, etc
    # @param name [String] Name of this Managed Source
    # @param parameters [Hash] Source-specific configuration parameters
    # @param resources [Array] Array of source-specific resources
    # @param auth [Array] Array of source-specific auth credentials
    def create(source_type, name, parameters = {}, resources = [], auth = [])
      params = {
        :source_type => source_type,
        :name => name
      }
      requires params

      params.merge!(
        { :auth => auth.is_a?(String) ? auth : MultiJson.dump(auth) }
      ) unless auth.empty?
      params.merge!(
        { :parameters => parameters.is_a?(String) ? parameters : MultiJson.dump(parameters) }
      ) unless parameters.empty?
      params.merge!(
        { :resources => resources.is_a?(String) ? resources : MultiJson.dump(resources) }
      ) if resources.length > 0
      DataSift.request(:POST, 'source/create', @config, params)
    end

    # Update a Managed Source
    #
    # @param id [String] ID of the Managed Source you are updating
    # @param source_type [String] Type of Managed Source you are updating
    # @param name [String] Name (or new name) of the Managed Source
    # @param parameters [Hash] Source-specific configuration parameters
    # @param resources [Array] Array of source-specific resources
    # @param auth [Array] Array of source-specific auth credentials
    def update(id, source_type, name, parameters = {}, resources = [], auth = [])
      raise BadParametersError.new('id,source_type and name are required') if id.nil? || source_type.nil? || name.nil?
      params = {
        :id => id,
        :source_type => source_type,
        :name => name
      }
      params.merge!({ :auth => MultiJson.dump(auth) }) if !auth.empty?
      params.merge!({ :parameters => MultiJson.dump(parameters) }) if !parameters.empty?
      params.merge!({ :resources => MultiJson.dump(resources) }) if resources.length > 0

      DataSift.request(:POST, 'source/update', @config, params)
    end

    # Delete a Managed Source
    #
    # @param id [String] ID of the Managed Source you are deleting
    def delete(id)
      raise BadParametersError.new('id is required') if id.nil?
      DataSift.request(:DELETE, 'source/delete', @config, { :id => id })
    end

    # Stop a Managed Source
    #
    # @param id [String] ID of the Managed Source you are stopping
    def stop(id)
      raise BadParametersError.new('id is required') if id.nil?
      DataSift.request(:POST, 'source/stop', @config, { :id => id })
    end

    # Start a Managed Source
    #
    # @param id [String] ID of the Managed Source you are starting
    def start(id)
      raise BadParametersError.new('id is required') if id.nil?
      DataSift.request(:POST, 'source/start', @config, { :id => id })
    end

    # Retrieve details of a Managed Source
    #
    # @param id [String] ID of the Managed Source you are getting. Omitting the
    #   ID will return a list of Managed Sources
    # @param source_type [String] Limits the list of Managed Sources returned to
    #   only sources of a specific source type if specified
    # @param page [Integer] Number of Managed Sources to return on one page of
    #   results
    # @param per_page [Integer] Number of Managed Sources to return per page
    def get(id = nil, source_type = nil, page = 1, per_page = 20)
      params = { :page => page, :per_page => per_page }
      params.merge!({ :id => id }) if !id.nil?
      params.merge!({ :source_type => source_type }) if !source_type.nil?

      DataSift.request(:GET, 'source/get', @config, params)
    end

    # Retrieve log details of Managed Sources
    #
    # @param id [String] ID of the Managed Source for which you are collecting
    #   logs
    # @param page [Integer] Number of Managed Source logs to return on one page
    #   of results
    # @param per_page [Integer] Number of Managed Source logs to return per page
    def log(id, page = 1, per_page = 20)
      raise BadParametersError.new('id is required') if id.nil?
      DataSift.request(:POST, 'source/log', @config, { :id => id, :page => page, :per_page => per_page })
    end
  end
end
