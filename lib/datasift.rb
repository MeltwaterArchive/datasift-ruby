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
require dir + '/dynamic_list'
require dir + '/dynamic_list_replace'
#
require 'rbconfig'

module DataSift
  #
  IS_WINDOWS              = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  VERSION                 = File.open(File.join(File.dirname(__FILE__), '../') + '/VERSION').first
  KNOWN_SOCKETS           = {}
  DETECT_DEAD_SOCKETS     = true
  SOCKET_DETECTOR_TIMEOUT = 6.5

  Thread.new do
    while DETECT_DEAD_SOCKETS
      now = Time.now.to_i
      KNOWN_SOCKETS.clone.map { |connection, last_time|
        connection.stream.reconnect if now - last_time > SOCKET_DETECTOR_TIMEOUT
      }
      sleep SOCKET_DETECTOR_TIMEOUT * 10
    end
  end

  class Client < ApiResource
    #+config+:: A hash containing configuration options for the client for e.g.
    # {username => 'some_user', api_key => 'ds_api_key', 'enable_ssl' => true, open_timeout => 30, timeout => 30}
    def initialize(config)
      if config.nil?
        raise InvalidConfigError.new('Config cannot be nil')
      end
      if !config.key?(:username) || !config.key?(:api_key)
        raise InvalidConfigError.new('A valid username and API key are required. ' +
          'You can check your API credentials at https://datasift.com/settings')
      end

      @config                   = config
      @historics                = DataSift::Historics.new(config)
      @push                     = DataSift::Push.new(config)
      @managed_source           = DataSift::ManagedSource.new(config)
      @managed_source_resource  = DataSift::ManagedSourceResource.new(config)
      @managed_source_auth      = DataSift::ManagedSourceAuth.new(config)
      @historics_preview        = DataSift::HistoricsPreview.new(config)
      @dynamic_list             = DataSift::DynamicList.new(config)
      @dynamic_list_replace     = DataSift::DynamicListReplace.new(config)
    end

    attr_reader :historics, :push, :managed_source, :managed_source_resource,
      :managed_source_auth, :historics_preview, :dynamic_list,
      :dynamic_list_replace

    ##
    # Checks if the syntax of the given CSDL is valid
    #+boolResponse+ If true then a boolean is returned indicating whether the
    #   CSDL is valid, otherwise the response object itself is returned
    def valid?(csdl, boolResponse = true)
      requires({ :csdl => csdl })
      res = DataSift.request(:POST, 'validate', @config, :csdl => csdl )
      boolResponse ? res[:http][:status] == 200 : res
    end

    ##
    # Compile CSDL code.
    #+csdl+:: The CSDL you wish to compile
    def compile(csdl)
      requires({ :csdl => csdl })
      DataSift.request(:POST, 'compile', @config, :csdl => csdl )
    end

    ##
    # Check the number of objects processed and delivered in a given period
    #+period+:: Can be "day", "hour", or "current", defaults to hour
    def usage(period = :hour)
      DataSift.request(:POST, 'usage', @config, :period => period )
    end

    ##
    # Calculate the DPU cost of consuming a stream.
    def dpu(hash)
      requires ({ :hash => hash })
      DataSift.request(:POST, 'dpu', @config, :hash => hash )
    end

    ##
    # Determine your credit balance or DPU balance.
    def balance
      DataSift.request(:POST, 'balance', @config)
    end

    ##
    # Collect a batch of interactions from a push queue
    def pull(id, size = 20_971_520, cursor = '')
      DataSift.request(:POST, 'pull', @config, { :id => id, :size => size, :cursor => cursor })
    end
  end

  # Generates and executes an HTTP request from the params provided
  # Params:
  # +method+:: the HTTP method to use e.g. GET,POST
  # +path+:: the DataSift path relevant to the base URL of the API
  # +username+:: API username
  # +api_key+:: DS api key
  # +params+:: A hash representing the params to use in the request, if its a
  #   GET, HEAD or DELETE request these params are used as query string params,
  #   if not they become form url encoded params
  # +headers+:: any headers to pass to the API, Authorization header is
  #   automatically included
  def self.request(method, path, config, params = {}, headers = {}, timeout = 30, open_timeout = 30, new_line_separated = false)
    validate config
    options = {}
    url = build_url(path, config)

    headers.update(
      :user_agent    => "DataSift/#{config[:api_version]} Ruby/v#{VERSION}",
      :authorization => "#{config[:username]}:#{config[:api_key]}",
      :content_type  => 'application/x-www-form-urlencoded'
    )

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      url += "#{URI.parse(url).query ? '&' : '?'}#{encode params}"
      payload = nil
    else
      payload = MultiJson.dump(params)
      headers.update({ :content_type => 'application/json' })
    end

    options.update(
      :headers      => headers,
      :method       => method,
      :open_timeout => open_timeout,
      :timeout      => timeout,
      :payload      => payload,
      :url          => url,
      :ssl_version  => OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version],
      :verify_ssl   => OpenSSL::SSL::VERIFY_PEER
    )

    begin
      response = RestClient::Request.execute options
      if !response.nil? && response.length > 0
        if new_line_separated
          res_arr = response.split("\n")
          data    = []
          res_arr.each { |e|
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
        :datasift => {
          :x_ratelimit_limit     => response.headers[:x_ratelimit_limit],
          :x_ratelimit_remaining => response.headers[:x_ratelimit_remaining],
          :x_ratelimit_cost      => response.headers[:x_ratelimit_cost]
        },
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
        if code && body
          error = MultiJson.load(body)
          handle_api_error(e.http_code, (error['error'] ? error['error'] : '') + " for URL #{url}")
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

  def self.build_url(path, config)
    'http' + (config[:enable_ssl] ? 's' : '') + '://' + config[:api_host] +
      '/' + config[:api_version] + '/' + path
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

  def self.handle_api_error(code, body)
    case code
    when 400
      raise BadRequestError.new(code, body)
    when 401
      raise AuthError.new(code, body)
    when 404
      raise ApiResourceNotFoundError.new(code, body)
    else
      raise DataSiftError.new(code, body)
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
      stream                    = WebsocketTD::Websocket.new('websocket.datasift.com', '/multi', "username=#{config[:username]}&api_key=#{config[:api_key]}")
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
        on_error.call(connection, ReconnectTimeoutError.new("Connecting to DataSift has failed, re-connection was attempted but
                                         multiple consecutive failures where encountered. As a result no further
                                         re-connection will be automatically attempted. Manually invoke connect() after
                                          investigating the cause of the failure, be sure to observe DataSift's
                                          re-connect policies available at http://dev.datasift.com/docs/streaming-api/reconnecting
                                          - Error { #{message}}"))
      end
    else
      sleep config[:retry_timeout]
      new_stream(config, on_delete, on_error, on_open, on_close)
    end
  end
end
