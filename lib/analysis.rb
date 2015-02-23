module DataSift
  #
  # Analysis class for accessing DataSift's Pylon API
  class Analysis < DataSift::ApiResource
    # Check Pylon CSDL is valid by making an /analysis/validate API call
    #
    # @param csdl [String] CSDL you wish to validate
    # @param boolResponse [Boolean] True if you want a boolean response.
    #   False if you want the full response object
    # @return [Boolean, Object] Dependent on value of boolResponse
    def valid?(csdl, boolResponse = true)
      params = { :csdl => csdl }
      requires params
      res = DataSift.request(:POST, 'analysis/validate', @config, params)
      boolResponse ? res[:http][:status] == 200 : res
    end

    # Compile Pylon CSDL by making an /analysis/compile API call
    #
    # @param csdl [String] CSDL you wish to compile
    # @return [Object] API reponse object
    def compile(csdl)
      params = { :csdl => csdl }
      requires params
      DataSift.request(:POST, 'analysis/compile', @config, params)
    end

    # Perform /analysis/get API call to query status of your Pylon recordings
    #
    # @param hash [String] Hash you with the get the status for. Excluding this
    #   will return a list of all recordings
    # @return [Object] API reponse object
    def get(hash = '')
      params = { :hash => hash }
      DataSift.request(:GET, 'analysis/get', @config, params)
    end

    # Start recording a Pylon filter by making an /analysis/start API call
    #
    # @param hash [String] CSDL you wish to begin (or resume) recording
    # @param name [String] Give your recording a name. Required when starting a
    #   new recording
    # @return [Object] API reponse object
    def start(hash, name = '')
      params = { :hash => hash }
      requires params
      params.merge!(:name => name)
      DataSift.request(:PUT, 'analysis/start', @config, params)
    end

    # Stop an active Pylon recording by making an /analysis/stop API call
    #
    # @param hash [String] CSDL you wish to stop recording
    # @return [Object] API reponse object
    def stop(hash)
      params = { :hash => hash }
      requires params
      DataSift.request(:PUT, 'analysis/stop', @config, params)
    end

    # Perform a Pylon analysis query by making an /analysis/analyze API call
    #
    # @param hash [String] Hash of the recording you wish to perform an
    #   analysis against
    # @param parameters [String] Parameters of the analysis you wish to perform.
    #   See the
    #   {http://dev.datasift.com/pylon/docs/api-endpoints/analysisanalyze
    #   /analysis/analyze API Docs} for full documentation
    # @param filter [String] Optional Pylon CSDL for a query filter
    # @param start_time [String] Optional start timestamp for filtering by date
    # @param end_time [String] Optional end timestamp for filtering by date
    # @return [Object] API reponse object
    def analyze(hash, parameters, filter = '', start_time = '', end_time = '')
      params = {
        :hash => hash,
        :parameters => parameters
      }
      requires params

      params.merge!(
        :filter => filter,
        :start => start_time,
        :end => end_time
      )
      DataSift.request(:POST, 'analysis/analyze', @config, params)
    end

    # Query the tag hierarchy on interactions populated by a particular
    #   recording
    #
    # @param hash [String] Hash of the recording you wish to query
    # @return [Object] API reponse object
    def tags(hash)
      params = { :hash => hash }
      requires params
      DataSift.request(:GET, 'analysis/tags', @config, params)
    end
  end
end
