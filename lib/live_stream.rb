module DataSift
  class LiveStream < DataSift::ApiResource

    @stream              = nil
    @on_datasift_message = lambda {}

    def initialize (config, stream)
      super(config)
      @stream        = stream
      @retry_timeout = 0
      @subscriptions = {}
      @connected     = false
    end

    attr_reader :connected, :stream, :retry_timeout, :subscriptions
    attr_writer :connected, :retry_timeout

    def on_datasift_message=(p)
      raise BadParametersError.new('on_ds_message - 3 parameters required') unless p.arity == 3
      @on_datasift_message = p
    end

    def connected?
      @connected
    end

    def fire_ds_message(message)
      hash = false
      if message.has_key?(:hash)
        hash = message[:hash]
      end
      message.merge!({
                         :is_failure => message[:status] == 'failure',
                         :is_success => message[:status] == 'success',
                         :is_warning => message[:status] == 'warning',
                         :is_tick    => message[:status] == 'connected'
                     })
      @on_datasift_message.call(self, message, hash)
    end

    def fire_on_message(hash, interaction)
      callback = @subscriptions[hash]
      if callback == nil
        raise StreamingMessageError.new "no valid on_message callback provided for stream #{hash} with message #{interaction}"
      end
      callback.call(interaction, self, hash)
    end

    def subscribe(hash, on_message)
      raise BadParametersError.new('on_message - 3 parameters required') unless on_message.arity == 3
      @subscriptions[hash] = on_message
      @stream.send "{ \"action\":\"subscribe\",\"hash\":\"#{hash}\"}"
    end

    def unsubscribe hash
      @stream.send "{ \"action\":\"unsubscribe\",\"hash\":\"#{hash}\"}"
    end
  end
end