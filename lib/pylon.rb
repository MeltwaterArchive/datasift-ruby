module DataSift
  #
  # Class for accessing DataSift's Pylon API
  class Pylon < DataSift::ApiResource
    # Check Pylon CSDL is valid by making an /pylon/validate API call
    #
    # @param csdl [String] CSDL you wish to validate
    # @param boolResponse [Boolean] True if you want a boolean response.
    #   False if you want the full response object
    # @return [Boolean, Object] Dependent on value of boolResponse
    def valid?(csdl, boolResponse = true)
      params = { :csdl => csdl }
      requires params
      res = DataSift.request(:POST, 'pylon/validate', @config, params)
      boolResponse ? res[:http][:status] == 200 : res
    end

    # Compile Pylon CSDL by making an /pylon/compile API call
    #
    # @param csdl [String] CSDL you wish to compile
    # @return [Object] API reponse object
    def compile(csdl)
      params = { :csdl => csdl }
      requires params
      DataSift.request(:POST, 'pylon/compile', @config, params)
    end

    # Perform /pylon/get API call to query status of your Pylon recordings
    #
    # @param hash [String] Hash you with the get the status for. Excluding this
    #   will return a list of all recordings
    # @return [Object] API reponse object
    def get(hash = '')
      params = { :hash => hash }
      DataSift.request(:GET, 'pylon/get', @config, params)
    end

    # Start recording a Pylon filter by making an /pylon/start API call
    #
    # @param hash [String] CSDL you wish to begin (or resume) recording
    # @param name [String] Give your recording a name. Required when starting a
    #   new recording
    # @return [Object] API reponse object
    def start(hash, name = '')
      params = { :hash => hash }
      requires params
      params.merge!(:name => name)
      DataSift.request(:PUT, 'pylon/start', @config, params)
    end

    # Stop an active Pylon recording by making an /pylon/stop API call
    #
    # @param hash [String] CSDL you wish to stop recording
    # @return [Object] API reponse object
    def stop(hash)
      params = { :hash => hash }
      requires params
      DataSift.request(:PUT, 'pylon/stop', @config, params)
    end

    # Perform a Pylon analysis query by making an /pylon/analyze API call
    #
    # @param hash [String] Hash of the recording you wish to perform an
    #   analysis against
    # @param parameters [String] Parameters of the analysis you wish to perform.
    #   See the
    #   {http://dev.datasift.com/pylon/docs/api-endpoints/pylonanalyze
    #   /pylon/analyze API Docs} for full documentation
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
      DataSift.request(:POST, 'pylon/analyze', @config, params)
    end

    # Query the tag hierarchy on interactions populated by a particular
    #   recording
    #
    # @param hash [String] Hash of the recording you wish to query
    # @return [Object] API reponse object
    def tags(hash)
      params = { :hash => hash }
      requires params
      DataSift.request(:GET, 'pylon/tags', @config, params)
    end
  end
end
