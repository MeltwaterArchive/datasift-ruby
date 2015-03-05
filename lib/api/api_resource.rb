module DataSift
  # Base API class
  class ApiResource
    include DataSift

    # Initializer to create global @config object
    #
    # @param config [Hash] Pass config object, including your DataSift username,
    #   API key and any other custom config parameters
    def initialize(config)
      @config = config
      config[:api_host] = 'api.datasift.com' unless config.key?(:api_host)
      config[:stream_host] = 'websocket.datasift.com' unless config.key?(:stream_host)
      config[:api_version] = 'v1' unless config.key?(:api_version)
      config[:enable_ssl] = false unless config.key?(:enable_ssl)
      # max 320 seconds retry - http://dev.datasift.com/docs/streaming-api/reconnecting
      config[:max_retry_time] = 320 unless config.key?(:max_retry_time)
      config[:retry_timeout] = 0 unless config.key?(:retry_timeout)
    end

    # Ensure parameters have been set
    #
    # @param params [Hash] Hash of parameters you need to check exist and are
    #   non-null values
    def requires(params)
      params.each { |k, v|
        if v == nil || v.to_s.length == 0
          raise InvalidParamError.new "#{k} is a required parameter, it cannot be nil or empty"
        end
      }
    end
  end
end
