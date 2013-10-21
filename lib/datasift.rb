dir = File.dirname(__FILE__)
#
require 'uri'
require 'rest_client'
require 'multi_json'
require 'websocket-eventmachine-client'
#
require dir + '/api/api_resource'
#
require dir + '/errors'
require dir + '/push'
require dir + '/historics'
require dir + '/historics_preview'
require dir + '/managed_source'
require dir + '/live_stream'

module DataSift
  API_URL        = 'http://api.datasift.com/'
  STREAM_URL     = 'ws://websocket.datasift.com/'
  VERSION        = '3.0.0'
  # max 320 seconds retry - http://dev.datasift.com/docs/streaming-api/reconnecting
  MAX_RETRY_TIME = 320

  class Client < ApiResource
    #+config+:: A hash containing configuration options for the client for e.g.
    # {username => 'some_user', api_key => 'ds_api_key', open_timeout => 30, timeout => 30}
    def initialize (config)
      if config == nil
        raise InvalidConfigError.new ('Config cannot be nil')
      end
      if config.key?(:api_key) == false || config.key?(:username) == false
        raise InvalidConfigError.new('A valid username and API key are required')
      end

      @config            = config
      @historics         = DataSift::Historics.new(config)
      @push              = DataSift::Push.new(config)
      @managed_source    = DataSift::ManagedSource.new(config)
      @historics_preview = DataSift::HistoricsPreview.new(config)
    end

    attr_reader :historics, :push, :managed_source, :historics_preview

    ##
    # Checks if the syntax of the given CSDL is valid
    def valid? csdl
      requires({:csdl => csdl})
      res= DataSift.request(:POST, 'validate', @config, {:csdl => csdl})
      res[:http][:status] == 200
    end

    ##
    # Compile CSDL code.
    #+csdl+:: The CSDL you wish to compile
    def compile csdl
      requires({:csdl => csdl})
      DataSift.request(:POST, 'compile', @config, {:csdl => csdl})
    end

    ##
    # Check the number of objects processed and delivered for a given time period.
    #+period+:: Can be "day", "hour", or "current", defaults to hour
    def usage period = :hour
      DataSift.request(:POST, 'usage', @config, {:period => period})
    end

    ##
    # Calculate the DPU cost of consuming a stream.
    def dpu hash
      requires ({:hash => hash})
      DataSift.request(:POST, 'dpu', @config, {:hash => hash})
    end

    ##
    # Determine your credit balance or DPU balance.
    def balance
      DataSift.request(:POST, 'balance', @config, {})
    end

    ##
    # Collect a batch of interactions from a push queue
    def pull(id, size = 20971520, cursor='')
      DataSift.request(:POST, 'pull', @config, {:id => id, :size => size, :cursor => cursor})
    end

  end


  # Generates and executes an HTTP request from the params provided
  # Params:
  # +method+:: the HTTP method to use e.g. GET,POST
  # +path+:: the DataSift path relevant to the base URL of the API
  # +username+:: API username
  # +api_key+:: DS api key
  # +params+:: A hash representing the params to use in the request, if it's a get,head or delete request these params
  # are used as query string params, if not they become form url encoded params
  # +headers+:: any headers to pass to the API, Authorization header is automatically included
  def self.request(method, path, config, params = {}, headers = {}, timeout=30, open_timeout=30)
    validate config
    options = {}
    url     = API_URL + path
    case method.to_s.downcase.to_sym
      when :get, :head, :delete
        url     += "#{URI.parse(url).query ? '&' : '?'}#{encode params}"
        payload = nil
      else
        payload = encode params
    end

    headers.update ({
        :user_agent    => "DataSift/v1 RubyBindings/#{VERSION} - Ruby V#{RUBY_PLATFORM}",
        :authorization => "#{config[:username]}:#{config[:api_key]}",
        :content_type  => 'application/x-www-form-urlencoded'
    })

    options.update(
        :headers      => headers,
        :method       => method,
        :open_timeout => open_timeout,
        :timeout      => timeout,
        :payload      => payload,
        :url          => url
    )

    begin
      response = RestClient::Request.execute options
      if response != nil && response.length > 0
        data = MultiJson.load response, :symbolize_keys => true
      else
        data = {}
      end
      {
          :data     => data,
          :datasift => {
              :x_ratelimit_limit     => response.headers[:x_ratelimit_limit],
              :x_ratelimit_remaining => response.headers[:x_ratelimit_remaining],
              :x_ratelimit_cost      => response.headers[:x_ratelimit_cost]
          },
          :http     => {
              :status  => response.code,
              :headers => response.headers
          }
      }
    rescue MultiJson::DecodeError => de
      raise DataSiftError.new response
    rescue SocketError => e
      process_client_error(e)
    rescue RestClient::ExceptionWithResponse => e
      begin
        code = e.http_code
        body = e.http_body
        if code && body
          error = MultiJson.load(body)
          handle_api_error(e.http_code, error['error'] + " for URL #{url}")
        else
          process_client_error(e)
        end
      rescue MultiJson::DecodeError
        process_client_error(e)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      process_client_error (e)
    end
  end

  #returns true if username and api key are set
  def self.is_invalid? config
    !config.key?(:username) || !config.key?(:api_key)
  end

  def self.validate conf
    if is_invalid? conf
      raise InvalidConfigError.new 'A username and api_key are required'
    end
  end

  def self.encode params
    URI.escape(params.collect { |k, v| "#{k}=#{v}" }.join('&'))
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
        message = 'Communication with DataSift failed. Are you able to resolve api.datasift.com?'
      else
        message = 'Unexpected error.'
    end
    raise ConnectionError.new(message + " (Network error: #{e.message})")
  end

  ##
  # a Proc/lambda callback to receive delete messages
  # DataSift and its customers are required to process Twitter's delete request, a delete handler must be provided
  # a Proc/lambda callback to receive errors
  # Because EventMachine is used errors can be raised from another thread, this method will receive any such errors
  def self.new_stream(config, on_delete, on_error, on_open = nil, on_close = nil)
    if on_delete == nil || on_error == nil
      raise NotConfiguredError.new 'on_delete and on_error are required before you can connect'
    end

    #raise InvalidTypeError.new 'on_delete must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)
    #raise InvalidTypeError.new 'on_error must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)

    ws_url = "ws://websocket.datasift.com/multi?username=#{config[:username]}&api_key=#{config[:api_key]}"
    begin
      stream     = WebSocket::EventMachine::Client.connect(:uri => ws_url)
      connection = LiveStream.new(config, stream)

      stream.onopen do
        connection.connected     = true
        connection.retry_timeout = 0
        on_open.call(connection) if on_open != nil
      end

      stream.onclose do
        connection.connected = false
        retry_connect(config, connection, on_delete, on_error, on_open, on_close, '', true)
      end
      stream.onerror do
        connection.connected = false
        on_error.call(connection) if on_close != nil
        retry_connect(config, connection, on_delete, on_error, on_open, on_close)
      end
      stream.onmessage do |msg, type|
        data = MultiJson.load(msg, :symbolize_keys => true)
        if data.has_key?(:deleted)
          on_delete.call(connection, data)
        elsif data.has_key?(:status)
          connection.fire_ds_message(data)
        else
          connection.fire_on_message(data[:hash], data[:data])
        end
      end
    rescue EventMachine::ConnectionError => e
      retry_connect(config, connection, on_delete, on_error, on_open, on_close, e.message)
    rescue Exception => e
      puts e.message
      retry_connect(config, connection, on_delete, on_error, on_open, on_close, e.message)
    end
    connection
  end

  def self.retry_connect(config, connection, on_delete, on_error, on_open, on_close, message = '', use_closed = false)
    connection.retry_timeout = connection.retry_timeout == 0 ? 10 : connection.retry_timeout * 2
    if connection.retry_timeout > MAX_RETRY_TIME
      if use_closed && on_close != nil
        on_close.call(connection)
      else
        on_error.call ReconnectTimeoutError.new "Connecting to DataSift has failed, re-connection was attempted but
                                         multiple consecutive failures where encountered. As a result no further
                                         re-connection will be automatically attempted. Manually invoke connect() after
                                          investigating the cause of the failure, be sure to observe DataSift's
                                          re-connect policies available at http://dev.datasift.com/docs/streaming-api/reconnecting
                                          - Error { #{message}}"
      end
    else
      sleep connection.retry_timeout
      new_stream(config, on_delete, on_error, on_open, on_close)
    end
  end
end