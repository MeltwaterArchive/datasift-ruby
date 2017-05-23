dir = File.dirname(__FILE__)
#
require 'uri'
require 'cgi'
require 'rest_client'
require 'multi_json'
require 'websocket_td'
#
require dir + '/api/api_resource'
#
require dir + '/errors'
require dir + '/push'
require dir + '/historics'
require dir + '/historics_preview'
require dir + '/managed_source'
require dir + '/managed_source_auth'
require dir + '/managed_source_resource'
require dir + '/live_stream'
require dir + '/pylon'
require dir + '/tasks'
require dir + '/account'
require dir + '/account_identity'
require dir + '/account_identity_token'
require dir + '/account_identity_limit'
require dir + '/odp'
require dir + '/version'
#
require 'rbconfig'

module DataSift
  #
  IS_WINDOWS              = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  KNOWN_SOCKETS           = {}
  DETECT_DEAD_SOCKETS     = true
  SOCKET_DETECTOR_TIMEOUT = 6.5

  GET = 'GET'.freeze
  HEAD = 'HEAD'.freeze
  DELETE = 'DELETE'.freeze
  APPLICATION_JSON = 'application/json'.freeze
  # Rate limits
  X_RATELIMIT_LIMIT = 'x_ratelimit_limit'.freeze
  X_RATELIMIT_REMAINING = 'x_ratelimit_remaining'.freeze
  X_RATELIMIT_COST = 'x_ratelimit_cost'.freeze
  X_TASKS_QUEUED = 'x_tasks_queued'.freeze
  X_TASKS_QUEUE_LIMIT = 'x_tasks_queue_limit'.freeze
  X_ANALYSIS_TASKS_QUEUE_LIMIT = 'x_analysis_tasks_queue_limit'.freeze
  X_ANALYSIS_TASKS_QUEUED = 'x_analysis_tasks_queued'.freeze
  X_INSIGHT_TASKS_QUEUE_LIMIT = 'x_insight_tasks_queue_limit'.freeze
  X_INSIGHT_TASKS_QUEUED = 'x_insight_tasks_queued'.freeze

  Thread.new do
    while DETECT_DEAD_SOCKETS
      now = Time.now.to_i
      KNOWN_SOCKETS.clone.map { |connection, last_time|
        connection.stream.reconnect if now - last_time > SOCKET_DETECTOR_TIMEOUT
      }
      sleep SOCKET_DETECTOR_TIMEOUT * 10
    end
  end

  # All API requests must be made by a Client object
  class Client < ApiResource
    # @param config [Hash] A hash containing configuration options for the
    #   client for e.g. { username: 'some_user', api_key: 'ds_api_key',
    #   enable_ssl: true, open_timeout: 30, timeout: 30 }
    def initialize(config)
      raise InvalidConfigError.new('Config cannot be nil') if config.nil?
      if !config.key?(:username) || !config.key?(:api_key)
        raise InvalidConfigError.new('A valid username and API key are required. ' +
          'You can check your API credentials at https://app.datasift.com/settings')
      end

      @config                   = config
      @historics                = DataSift::Historics.new(config)
      @push                     = DataSift::Push.new(config)
      @managed_source           = DataSift::ManagedSource.new(config)
      @managed_source_resource  = DataSift::ManagedSourceResource.new(config)
      @managed_source_auth      = DataSift::ManagedSourceAuth.new(config)
      @historics_preview        = DataSift::HistoricsPreview.new(config)
      @pylon                    = DataSift::Pylon.new(config)
      @task                     = DataSift::Task.new(config)
      @account                  = DataSift::Account.new(config)
      @account_identity         = DataSift::AccountIdentity.new(config)
      @account_identity_token   = DataSift::AccountIdentityToken.new(config)
      @account_identity_limit   = DataSift::AccountIdentityLimit.new(config)
      @odp                      = DataSift::Odp.new(config)
    end

    attr_reader :config, :historics, :push, :managed_source, :managed_source_resource,
      :managed_source_auth, :historics_preview, :pylon, :account, :account_identity,
      :account_identity_token, :account_identity_limit, :odp, :task

    # Checks if the syntax of the given CSDL is valid
    #
    # @param boolResponse [Boolean] If true a boolean is returned indicating
    # whether the CSDL is valid, otherwise the full response object is returned
    def valid?(csdl, boolResponse = true)
      requires({ :csdl => csdl })
      res = DataSift.request(:POST, 'validate', @config, :csdl => csdl )
      boolResponse ? res[:http][:status] == 200 : res
    end

    # Compile CSDL code.
    #
    # @param csdl [String] The CSDL you wish to compile
    # @return [Object] API reponse object
    def compile(csdl)
      requires({ :csdl => csdl })
      DataSift.request(:POST, 'compile', @config, :csdl => csdl )
    end

    # Check the number of objects processed for a given time period
    #
    # @param period [String] Can be "day", "hour", or "current"
    # @return [Object] API reponse object
    def usage(period = :hour)
      DataSift.request(:POST, 'usage', @config, :period => period )
    end

    # Calculate the DPU cost of running a filter, or Historics query
    #
    # @param hash [String] CSDL hash for which you wish to find the DPU cost
    # @param historics_id [String] ID of Historics query for which you wish to
    #   find the DPU cost
    # @return [Object] API reponse object
    def dpu(hash = '', historics_id = '')
      fail ArgumentError, 'Must pass a filter hash or Historics ID' if
        hash.empty? && historics_id.empty?
      fail ArgumentError, 'Must only pass hash or Historics ID; not both' unless
        hash.empty? || historics_id.empty?

      params = {}
      params.merge!(hash: hash) unless hash.empty?
      params.merge!(historics_id: historics_id) unless historics_id.empty?

      DataSift.request(:POST, 'dpu', @config, params)
    end

    # Determine your credit balance or DPU balance.
    #
    # @return [Object] API reponse object
    def balance
      DataSift.request(:POST, 'balance', @config)
    end

    # Collect a batch of interactions from a push queue
    #
    # @param id [String] ID of the Push subscription you wish to pull data from
    # @param size [Integer] Max size (bytes) of the data you can receive from a
    #   /pull API call
    # @param cursor [String] A pointer into the Push queue associated with your
    #   last delivery
    # @return [Object] API reponse object
    def pull(id, size = 20_971_520, cursor='')
      DataSift.request(:POST, 'pull', @config, { :id => id, :size => size,
        :cursor => cursor })
    end
  end

  # Generates and executes an HTTP request from the params provided
  #
  # @param method [Symbol] The HTTP method to use
  # @param path [String] The DataSift path relevant to the base URL of the API
  # @param config [Object] The config object containing user details
  # @param params [Hash] A hash representing the params to use in the request
  # @param headers [Hash] Any headers to pass to the API
  # @param timeout [Integer] Set the request timeout
  # @param open_timeout [Integer] Set the request open timeout
  # @param new_line_separated [Boolean] Will response be newline separated?
  def self.request(method, path, config, params = {}, headers = {},
    timeout = 30, open_timeout = 30, new_line_separated = false)

    validate config
    url = build_url(path, config)

    headers.update(
      :user_agent    => "DataSift/#{config[:api_version]} Ruby/v#{DataSift::VERSION}",
      :authorization => "#{config[:username]}:#{config[:api_key]}",
      :accept  => '*/*'
    )

    case method.to_s.upcase
    when GET, HEAD, DELETE
      url += "#{URI.parse(url).query ? '&' : '?'}#{encode params}"
      payload = nil
    else
      payload = params.is_a?(String) ? params : MultiJson.dump(params)
      headers.update({ :content_type => APPLICATION_JSON })
    end

    options = {
      :headers      => headers,
      :method       => method,
      :open_timeout => open_timeout,
      :timeout      => timeout,
      :payload      => payload,
      :url          => url,
      :ssl_version  => config[:ssl_version],
      :verify_ssl   => OpenSSL::SSL::VERIFY_PEER
    }

    response = nil
    begin
      response = RestClient::Request.execute options
      if !response.nil? && response.length > 0
        if new_line_separated
          data = []
          response.split("\n").each { |e|
            interaction = MultiJson.load(e, :symbolize_keys => true)
            data.push(interaction)
            if params.key? :on_interaction
              params[:on_interaction].call(interaction)
            end
          }
        else
          data = MultiJson.load(response, :symbolize_keys => true)
        end
      else
        data = {}
      end
      {
        :data => data,
        :datasift => build_headers(response.headers),
        :http => {
          :status  => response.code,
          :headers => response.headers
        }
      }
    rescue MultiJson::DecodeError
      raise DataSiftError.new response
    rescue SocketError => e
      process_client_error(e)
    rescue RestClient::ExceptionWithResponse => e
      begin
        code = e.http_code
        body = e.http_body
        error = nil
        if code && body
          begin
            error = MultiJson.load(body)
          rescue MultiJson::ParseError
            # In cases where we receive 502 responses, Nginx may send HTML rather than JSON
            error = body
          end
          response_on_error = {
            :data => nil,
            :datasift => build_headers(e.response.headers),
            :http => {
              :status  => e.response.code,
              :headers => e.response.headers
            }
          }
          handle_api_error(e.http_code, (error['error'] ? error['error'] : '') + " for URL #{url}", response_on_error)
        else
          process_client_error(e)
        end
      rescue MultiJson::DecodeError
        process_client_error(e)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      process_client_error(e)
    end
  end

  # Only to be used for building URI paths for /pylon API calls. API v1.4+ requires a 'service'
  #   param to be passed as part of the URI. This checks the API version, and adds the service
  #   if necessary
  def build_path(service, path, config)
    # We need to add the service param to PYLON API URLs for API v1.4+
    if config[:api_version].split('v')[1].to_f >= 1.4
      split_path = path.split('/')
      path = split_path[0] + '/' + service + '/' + split_path[1]
    end
    puts path

    return path
  end

  private

  def self.build_url(path, config)
    url = 'http' + (config[:enable_ssl] ? 's' : '') + '://' + config[:api_host]
    if !config[:api_version].nil?
      url += '/' + config[:api_version]
    end
    url += '/' + path
  end

  # Returns true if username or api key are not set
  def self.is_invalid?(config)
    !config.key?(:username) || !config.key?(:api_key)
  end

  def self.validate(config)
    if is_invalid? config
      raise InvalidConfigError.new 'A username and api_key are required'
    end
  end

  def self.encode(params)
    params.collect { |param, value| [param, CGI.escape(value.to_s)].join('=') }.join('&')
  end

  def self.build_headers(headers)
    # rest_client downcases, and replaces hyphens in headers with underscores. Actual headers
    #   returned by DS API can be found at:
    #   http://dev.datasift.com/docs/platform/api/rest-api/api-rate-limiting
    response = {}
    response.merge!(X_TASKS_QUEUED => headers[:x_tasks_queued]) if headers.key?(:x_tasks_queued)
    response.merge!(X_TASKS_QUEUE_LIMIT => headers[:x_tasks_queue_limit]) if headers.key?(:x_tasks_queue_limit)
    response.merge!(X_ANALYSIS_TASKS_QUEUE_LIMIT => headers[:x_analysis_tasks_queue_limit]) if headers.key?(:x_analysis_tasks_queue_limit)
    response.merge!(X_ANALYSIS_TASKS_QUEUED => headers[:x_analysis_tasks_queued]) if headers.key?(:x_analysis_tasks_queued)
    response.merge!(X_INSIGHT_TASKS_QUEUE_LIMIT => headers[:x_insight_tasks_queue_limit]) if headers.key?(:x_insight_tasks_queue_limit)
    response.merge!(X_INSIGHT_TASKS_QUEUED => headers[:x_insight_tasks_queued]) if headers.key?(:x_insight_tasks_queued)
    response.merge!(
      X_RATELIMIT_LIMIT => headers[:x_ratelimit_limit],
      X_RATELIMIT_REMAINING => headers[:x_ratelimit_remaining],
      X_RATELIMIT_COST => headers[:x_ratelimit_cost]
    )
  end

  def self.handle_api_error(code, body, response)
    case code
    when 400
      raise BadRequestError.new(code, body, response)
    when 401
      raise AuthError.new(code, body, response)
    when 403
      raise ForbiddenError.new(code, body, response)
    when 404
      raise ApiResourceNotFoundError.new(code, body, response)
    when 405
      raise MethodNotAllowedError.new(code, body, response)
    when 409
      raise ConflictError.new(code, body, response)
    when 410
      raise GoneError.new(code, body, response)
    when 412
      raise PreconditionFailedError.new(code, body, response)
    when 413
      raise PayloadTooLargeError.new(code, body, response)
    when 415
      raise UnsupportedMediaTypeError.new(code, body, response)
    when 422
      raise UnprocessableEntityError.new(code, body, response)
    when 429
      raise TooManyRequestsError.new(code, body, response)
    when 500
      raise InternalServerError.new(code, body, response)
    when 502
      raise BadGatewayError.new(code, body, response)
    when 503
      raise ServiceUnavailableError.new(code, body, response)
    when 504
      raise GatewayTimeoutError.new(code, body, response)
    else
      raise DataSiftError.new(code, body, response)
    end
  end

  def self.process_client_error(e)
    case e
    when RestClient::ServerBrokeConnection, RestClient::RequestTimeout
      message = 'Unable to connect to DataSift. Please check your connection and try again'
    when RestClient::SSLCertificateNotVerified
      message = 'Failed to complete SSL verification'
    when SocketError
      message = 'Communication with DataSift failed. Are you able to resolve the API hostname?'
    else
      message = 'Unexpected error.'
    end
    raise ConnectionError.new(message + " (Network error: #{e.message})")
  end

  ##
  # A Proc/lambda callback to receive delete messages.
  # DataSift and its customers are required to process Twitter's Tweet delete
  #   requests; a delete handler must be provided.
  # A Proc/lambda callback to receive errors
  # Because EventMachine is used errors can be raised from another thread, this
  #   method will receive any such errors
  def self.new_stream(config, on_delete, on_error, on_open = nil, on_close = nil)
    if on_delete.nil? || on_error.nil?
      raise NotConfiguredError.new 'on_delete and on_error are required before you can connect'
    end
    raise BadParametersError.new('on_delete - 2 parameter required') unless on_delete.arity == 2
    raise BadParametersError.new('on_error - 2 parameter required') unless on_error.arity == 2
    unless on_open.nil?
      raise BadParametersError.new('on_open - 1 parameter required') unless on_open.arity == 1
    end
    unless on_close.nil?
      raise BadParametersError.new('on_close - 2 parameter required') unless on_close.arity == 2
    end
    begin
      stream                    = WebsocketTD::Websocket.new(config[:stream_host], '/multi', "username=#{config[:username]}&api_key=#{config[:api_key]}")
      connection                = LiveStream.new(config, stream)
      KNOWN_SOCKETS[connection] = Time.new.to_i
      stream.on_ping            = lambda { |data|
        KNOWN_SOCKETS[connection] = Time.new.to_i
      }
      stream.on_open            = lambda {
        connection.connected     = true
        connection.retry_timeout = 0
        on_open.call(connection) unless on_open.nil?
      }

      stream.on_close = lambda { |message|
        connection.connected = false
        retry_connect(config, connection, on_delete, on_error, on_open, on_close, message, true)
      }
      stream.on_error = lambda { |message|
        connection.connected = false
        retry_connect(config, connection, on_delete, on_error, on_open, on_close, message)
      }
      stream.on_message=lambda { |msg|
        data = MultiJson.load(msg.data, :symbolize_keys => true)
        KNOWN_SOCKETS[connection] = Time.new.to_i
        if data.key?(:deleted)
          on_delete.call(connection, data)
        elsif data.key?(:status)
          connection.fire_ds_message(data)
        elsif data.key?(:reconnect)
          connection.stream.reconnect
        else
          connection.fire_on_message(data[:hash], data[:data])
        end
      }
    rescue Exception => e
      case e
      when DataSiftError, ArgumentError
        raise e
      else
        retry_connect(config, connection, on_delete, on_error, on_open, on_close, e.message)
      end
    end
    connection
  end

  def self.retry_connect(config, connection, on_delete, on_error, on_open, on_close, message = '', use_closed = false)
    config[:retry_timeout] = config[:retry_timeout] == 0 || config[:retry_timeout].nil? ? 10 : config[:retry_timeout] * 2
    connection.retry_timeout = config[:retry_timeout]

    if config[:retry_timeout] > config[:max_retry_time]
      if use_closed && !on_close.nil?
        on_close.call(connection, message)
      else
        on_error.call(connection, ReconnectTimeoutError.new("Connecting to DataSift has " \
          "failed, re-connection was attempted but multiple consecutive failures where " \
          "encountered. As a result no further re-connection will be automatically " \
          "attempted. Manually invoke connect() after investigating the cause of the " \
          "failure, be sure to observe DataSift's re-connect policies available at " \
          "https://dev.datasift.com/docs/platform/api/streaming-api/reconnecting - Error {#{message}}"))
      end
    else
      sleep config[:retry_timeout]
      new_stream(config, on_delete, on_error, on_open, on_close)
    end
  end
end
