module DataSift
  #
  # Class for accessing DataSift's PYLON API
  class Pylon < DataSift::ApiResource
    # Check PYLON CSDL is valid by making an /pylon/validate API call
    #
    # @param csdl [String] CSDL you wish to validate
    # @param boolResponse [Boolean] True if you want a boolean response.
    # @param service [String] The PYLON service to make this API call against
    #   False if you want the full response object
    # @return [Boolean, Object] Dependent on value of boolResponse
    def valid?(csdl = '', boolResponse = true, service = 'facebook')
      fail BadParametersError, 'csdl is required' if csdl.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = { csdl: csdl }

      res = DataSift.request(:POST, build_path(service, 'pylon/validate', @config), @config, params)
      boolResponse ? res[:http][:status] == 200 : res
    end

    # Compile PYLON CSDL by making an /pylon/compile API call
    #
    # @param csdl [String] CSDL you wish to compile
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def compile(csdl, service = 'facebook')
      fail BadParametersError, 'csdl is required' if csdl.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = { csdl: csdl }

      DataSift.request(:POST, build_path(service, 'pylon/compile', @config), @config, params)
    end

    # Perform /pylon/get API call to query status of your PYLON recordings
    #
    # @param hash [String] Hash you with the get the status for
    # @param id [String] The ID of the PYLON recording to get
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def get(hash = '', id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(id: id) unless id.empty?

      DataSift.request(:GET, build_path(service, 'pylon/get', @config), @config, params)
    end

    # Perform /pylon/get API call to list all PYLON Recordings
    #
    # @param page [Integer] Which page of recordings to retreive
    # @param per_page [Integer] How many recordings to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    #   order
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def list(page = nil, per_page = nil, order_by = '', order_dir = '', service = 'facebook')
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(page: page) unless page.nil?
      params.merge!(per_page: per_page) unless per_page.nil?
      params.merge!(order_by: order_by) unless order_by.empty?
      params.merge!(order_dir: order_dir) unless order_dir.empty?

      DataSift.request(:GET, build_path(service, 'pylon/get', @config), @config, params)
    end

    # Perform /pylon/update API call to update a given PYLON Recording
    #
    # @param id [String] The ID of the PYLON recording to update
    # @param hash [String] The CSDL filter hash this recording should be subscribed to
    # @param name [String] Update the name of your recording
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def update(id, hash = '', name = '', service = 'facebook')
      fail BadParametersError, 'service is required' if service.empty?

      params = { id: id }
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(name: name) unless name.empty?

      DataSift.request(:PUT, build_path(service, 'pylon/update', @config), @config, params)
    end

    # Start recording a PYLON filter by making an /pylon/start API call
    #
    # @param hash [String] CSDL you wish to begin (or resume) recording
    # @param name [String] Give your recording a name. Required when starting a
    # @param id [String] ID of the recording you wish to start
    #   new recording
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def start(hash = '', name = '', id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(name: name) unless name.empty?
      params.merge!(id: id) unless id.empty?

      DataSift.request(:PUT, build_path(service, 'pylon/start', @config), @config, params)
    end

    # Restart an existing PYLON recording by making an /pylon/start API call with a recording ID
    #
    # @param id [String] CSDL you wish to begin (or resume) recording
    # @param name [String] Give your recording a name. Required when starting a
    #   new recording
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def restart(id, name = '', service = 'facebook')
      fail BadParametersError, 'id is required' if id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = { id: id }
      params.merge!(name: name) unless name.empty?

      DataSift.request(:PUT, build_path(service, 'pylon/start', @config), @config, params)
    end

    # Stop an active PYLON recording by making an /pylon/stop API call
    #
    # @param hash [String] CSDL you wish to stop recording
    # @param id [String] ID of the recording you wish to stop
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def stop(hash = '', id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(id: id) unless id.empty?

      DataSift.request(:PUT, build_path(service, 'pylon/stop', @config), @config, params)
    end

    # Perform a PYLON analysis query by making an /pylon/analyze API call
    #
    # @param hash [String] Hash of the recording you wish to perform an
    #   analysis against
    # @param parameters [String] Parameters of the analysis you wish to perform.
    #   See the
    #   {http://dev.datasift.com/pylon/docs/api-endpoints/pylonanalyze
    #   /pylon/analyze API Docs} for full documentation
    # @param filter [String] Optional PYLON CSDL for a query filter
    # @param start_time [Integer] Optional start timestamp for filtering by date
    # @param end_time [Integer] Optional end timestamp for filtering by date
    # @param id [String] ID of the recording you wish to analyze
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def analyze(hash = '', parameters = '', filter = '', start_time = nil, end_time = nil, id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'parameters is required' if parameters.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = { parameters: parameters }
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(id: id) unless id.empty?
      params.merge!(filter: filter) unless filter.empty?
      params.merge!(start: start_time) unless start_time.nil?
      params.merge!(end: end_time) unless end_time.nil?

      DataSift.request(:POST, build_path(service, 'pylon/analyze', @config), @config, params)
    end

    # Query the tag hierarchy on interactions populated by a particular
    #   recording
    #
    # @param hash [String] Hash of the recording you wish to query
    # @param id [String] ID of the recording you wish to query
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def tags(hash = '', id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(id: id) unless id.empty?

      DataSift.request(:GET, build_path(service, 'pylon/tags', @config), @config, params)
    end

    # Hit the PYLON Sample endpoint to pull public sample data from a PYLON recording
    #
    # @param hash [String] The CSDL hash that identifies the recording you want to sample
    # @param count [Integer] Optional number of public interactions you wish to receive
    # @param start_time [Integer] Optional start timestamp for filtering by date
    # @param end_time [Integer] Optional end timestamp for filtering by date
    # @param filter [String] Optional PYLON CSDL for a query filter
    # @param id [String] ID of the recording you wish to sample
    # @param service [String] The PYLON service to make this API call against
    # @return [Object] API reponse object
    def sample(hash = '', count = nil, start_time = nil, end_time = nil, filter = '', id = '', service = 'facebook')
      fail BadParametersError, 'hash or id is required' if hash.empty? && id.empty?
      fail BadParametersError, 'service is required' if service.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(id: id) unless id.empty?
      params.merge!(count: count) unless count.nil?
      params.merge!(start_time: start_time) unless start_time.nil?
      params.merge!(end_time: end_time) unless end_time.nil?

      if filter.empty?
        DataSift.request(:GET, build_path(service, 'pylon/sample', @config), @config, params)
      else
        params.merge!(filter: filter)
        DataSift.request(:POST, build_path(service, 'pylon/sample', @config), @config, params)
      end
    end
  end
end
