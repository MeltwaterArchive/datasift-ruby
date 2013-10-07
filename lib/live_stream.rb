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
      @connected     = false
    end

    def connect(on_connect, on_delete, on_error, on_open = nil, on_close = nil)

      if @stream == nil
        EM.run do
          if on_delete == nil || on_error == nil
            raise NotConfiguredError.new 'on_delete and on_error are required before you can connect'
          end

          #raise InvalidTypeError.new 'on_delete must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)
          #raise InvalidTypeError.new 'on_error must be a Proc, e.g. lambda{ |e| puts e.message}' unless proc.kind_of?(Proc)

          @on_delete = on_delete
          @on_error  = on_error

          ws_url = "ws://websocket.datasift.com/multi?username=#{@config[:username]}&api_key=#{@config[:api_key]}"
          begin
            @stream = WebSocket::EventMachine::Client.connect(:uri => ws_url)

            @stream.onopen do
              @connected     = true
              @retry_timeout = 0
              on_open.call if on_open != nil
            end

            @stream.onclose do
              @connected = false
              @stream    = nil
              on_close.call if on_close != nil
              #retry_connect(on_connect, on_delete, on_error, on_open, on_close)
            end

            @stream.onmessage do |msg, type|
              data        = MultiJson.load msg, :symbolize_keys => true
              hash        = data[:hash]
              interaction = data[:data]
              puts "Received message (#{type}): #{hash} ==> #{interaction}"
            end
          rescue EventMachine::ConnectionError => e
            retry_connect(on_connect, on_delete, on_error, on_open, on_close, e.message)
          rescue Exception => e
            puts e.message
          end
          on_connect.call
        end
      end
    end

    def retry_connect(on_connect, on_delete, on_error, on_open, on_close, message = '')
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
        connect(on_connect, on_delete, on_error, on_open, on_close)
      end
    end

    def connected?
      @connected
    end

    def subscribe hash
      @stream.send "{ \"action\":\"subscribe\",\"hash\":\"#{hash}\"}"
    end

    def unsubscribe hash
      @stream.send "{ \"action\":\"unsubscribe\",\"hash\":\"#{hash}\"}"
    end
  end
end