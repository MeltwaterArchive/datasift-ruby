module DataSift
  class LiveStream < DataSift::ApiResource
    ##
    # a Proc/lambda callback to receive errors
    # Because EventMachine is used errors can be raised from another thread, this method will receive any such errors
    @on_error      = nil
    ##
    # a Proc/lambda callback to receive delete messages
    # DataSift and its customers are required to process Twitter's delete request, a delete handler must be provided
    @on_delete     = nil
    @stream        = nil
    # max 320 seconds retry - http://dev.datasift.com/docs/streaming-api/reconnecting
    MAX_RETRY_TIME = 320

    def initialize(config)
      super
      @retry_timeout = 0
      @subscriptions = {}
    end

    def on_delete=(proc)
      raise InvalidTypeError.new 'on_delete must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)
      @on_delete = proc
    end

    def on_error=(proc)
      raise InvalidTypeError.new 'on_error must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)
      @on_error = proc
    end

    def connect
      if @on_delete == nil || @on_error == nil
        raise NotConfiguredError.new 'on_delete and on_error are required before you can connect'
      end

      if @stream == nil
        EM.run do
          ws_url = "ws://websocket.datasift.com/multi?username=#{@config[:username]}&api_key=#{@config[:api_key]}"
          begin
            @stream = WebSocket::EventMachine::Client.connect(:uri => ws_url, :version => 13)

            @stream.onopen do
              @retry_timeout = 0
            end

            @stream.onclose do
              @stream = nil
              retry_connect
            end

            @stream.onmessage do |msg, type|
              data        = MultiJson.load msg, :symbolize_keys => true
              hash        = data[:hash]
              interaction = data[:data]
              puts "Received message (#{type}): #{hash} ==> #{interaction}"
            end
          rescue EventMachine::ConnectionError => e
            retry_connect(e.message)
          end
        end
      end
    end

    def retry_connect(message = '')
      @retry_timeout = @retry_timeout == 0 ? 10 : @retry_timeout * 2
      if @retry_timeout > MAX_RETRY_TIME
        @on_error.call ReconnectTimeoutError.new "Connecting to DataSift has failed, re-connection was attempted but
                                       multiple consecutive failures where encountered. As a result no further
                                       re-connection will be automatically attempted. Manually invoke connect() after
                                        investigating the cause of the failure, be sure to observe DataSift\'s
                                        re-connect policies available at http://dev.datasift.com/docs/streaming-api/reconnecting
                                        - Error { #{message}}"
      else
        sleep @retry_timeout
        connect
      end
    end

    def subscribe hash
      connect
      @stream.send "{ \"action\":\"subscribe\",\"hash\":\"#{hash}\"}"
    end

    def unsubscribe hash
      connect
      @stream.send "{ \"action\":\"unsubscribe\",\"hash\":\"#{hash}\"}"
    end
  end
end