module DataSift
  #
  # Class for accessing DataSift's PYLON API
  class Pylon < DataSift::ApiResource
    # Check PYLON CSDL is valid by making an /pylon/validate API call
    #
    # @param csdl [String] CSDL you wish to validate
    # @param boolResponse [Boolean] True if you want a boolean response.
    #   False if you want the full response object
    # @return [Boolean, Object] Dependent on value of boolResponse
    def valid?(csdl = '', boolResponse = true)
      fail BadParametersError, 'csdl is required' if csdl.empty?
      params = { csdl: csdl }

      res = DataSift.request(:POST, 'pylon/validate', @config, params)
      boolResponse ? res[:http][:status] == 200 : res
    end

    # Compile PYLON CSDL by making an /pylon/compile API call
    #
    # @param csdl [String] CSDL you wish to compile
    # @return [Object] API reponse object
    def compile(csdl)
      fail BadParametersError, 'csdl is required' if csdl.empty?
      params = { csdl: csdl }

      DataSift.request(:POST, 'pylon/compile', @config, params)
    end

    # Perform /pylon/get API call to query status of your PYLON recordings
    #
    # @param hash [String] Hash you with the get the status for
    # @return [Object] API reponse object
    def get(hash)
      fail BadParametersError, 'hash is required' if hash.empty?
      params = { hash: hash }

      DataSift.request(:GET, 'pylon/get', @config, params)
    end

    # Perform /pylon/get API call to list all PYLON Recordings
    #
    # @param page [Integer] Which page of recordings to retreive
    # @param per_page [Integer] How many recordings to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    #   order
    # @return [Object] API reponse object
    def list(page = nil, per_page = nil, order_by = '', order_dir = '')
      params = {}
      params.merge!(page: page) unless page.nil?
      params.merge!(per_page: per_page) unless per_page.nil?
      params.merge!(order_by: order_by) unless order_by.empty?
      params.merge!(order_dir: order_dir) unless order_dir.empty?

      DataSift.request(:GET, 'pylon/get', @config, params)
    end

    # Start recording a PYLON filter by making an /pylon/start API call
    #
    # @param hash [String] CSDL you wish to begin (or resume) recording
    # @param name [String] Give your recording a name. Required when starting a
    #   new recording
    # @return [Object] API reponse object
    def start(hash = '', name = '')
      fail BadParametersError, 'hash is required' if hash.empty?
      params = { hash: hash }
      params.merge!(name: name) unless name.empty?

      DataSift.request(:PUT, 'pylon/start', @config, params)
    end

    # Stop an active PYLON recording by making an /pylon/stop API call
    #
    # @param hash [String] CSDL you wish to stop recording
    # @return [Object] API reponse object
    def stop(hash)
      fail BadParametersError, 'hash is required' if hash.empty?
      params = { hash: hash }

      DataSift.request(:PUT, 'pylon/stop', @config, params)
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
    # @return [Object] API reponse object
    def analyze(hash = '', parameters = '', filter = '', start_time = nil, end_time = nil)
      fail BadParametersError, 'hash is required' if hash.empty?
      fail BadParametersError, 'parameters is required' if parameters.empty?
      params = {
        hash: hash,
        parameters: parameters
      }
      params.merge!(filter: filter) unless filter.empty?
      params.merge!(start: start_time) unless start_time.nil?
      params.merge!(end: end_time) unless end_time.nil?

      DataSift.request(:POST, 'pylon/analyze', @config, params)
    end

    # Query the tag hierarchy on interactions populated by a particular
    #   recording
    #
    # @param hash [String] Hash of the recording you wish to query
    # @return [Object] API reponse object
    def tags(hash)
      fail BadParametersError, 'hash is required' if hash.empty?
      params = { hash: hash }

      DataSift.request(:GET, 'pylon/tags', @config, params)
    end
  end
end
