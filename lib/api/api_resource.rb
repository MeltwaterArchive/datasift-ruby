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
      config[:api_host] = 'api.datasift.com' unless config.has_key?(:api_host)
      config[:stream_host] = 'websocket.datasift.com' unless config.has_key?(:stream_host)
      config[:ingestion_host] = 'in.datasift.com' unless config.has_key?(:ingestion_host)
      config[:api_version] = 'v1.2' unless config.has_key?(:api_version)
      config[:enable_ssl] = true unless config.has_key?(:enable_ssl)

      ssl_default = "TLSv1_2"
      if RUBY_VERSION.to_i == 1
        # Ruby 1.x does not seem to support > TLSv1
        ssl_default = "TLSv1"
      end
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = config[:ssl_version] ||
        ssl_default

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
