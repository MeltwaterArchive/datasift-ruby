module DataSift
  #This is the base class for all StreamConsumer implementation.
  class StreamConsumer
    #Constant for the HTTP StreamConsumer implementation option.
    TYPE_HTTP      = 'HTTP'

    #Constant for the "stopped" status.
    STATE_STOPPED  = 0
    #Constant for the "starting" status.
    STATE_STARTING = 1
    #Constant for the "running" status.
    STATE_RUNNING  = 2
    #Constant for the "stopping" status.
    STATE_STOPPING = 3

    #Factory function. Creates a StreamConsumer-derived object for the given
    #type.
    #=== Parameters
    #* +type+ - Use the TYPE_ constants
    #* +definition+ - CSDL string or a Definition object.
    #=== Returns
    #A StreamConsumer-derived object.
    def self.factory(user, type, definition)
      type   ||= TYPE_HTTP
      @klass = Module.const_get('DataSift').const_get('StreamConsumer_' + type)
      @klass.new(user, definition)
    end

    #Whether the consumer should automatically try to reconnect if the
    #connection is dropped.
    attr_accessor :auto_reconnect
    #The current state of the consumer.
    attr_reader :state
    #The reason the consumer was stopped.
    attr_reader :stop_reason

    #Constructor. Do not use this directly, use the factory method instead.
    #=== Parameters
    #* +user+ - The user this consumer will run as.
    #* +definition+ - CSDL string or a Definition object.
    def initialize(user, definition)
      raise InvalidDataError, 'Please supply a valid User object when creating a Definition object.' unless user.is_a? DataSift::User

      if definition.is_a? String
        @definition = user.createDefinition(definition)
      elsif definition.is_a? Definition
        @definition = definition
      else
        raise InvalidDataError, 'The definition must be a CSDL string or a DataSift_Definition object'
      end

      @user           = user
      @auto_reconnect = true
      @stop_reason    = 'Unknown reason'
      @state          = STATE_STOPPED
      @stream_timeout = 65

      # Get the hash which will compile the CSDL if necessary
      @definition.hash
    end

    #Called when a deletion notification is received.
    #=== Parameters
    #* +interaction+ - Minimal details about the interaction that was deleted.
    def onDeleted(&block)
      if block_given?
        @on_deleted = block
        self
      else
        @on_deleted
      end
    end

    #This is called when an error message is received.
    #=== Parameters
    #* +message+ - The error message.
    def onError(&block)
      if block_given?
        @on_error = block
        self
      else
        @on_error
      end
    end

    #This is called when an error message is received.
    #=== Parameters
    #* +message+ - The error message.
    def onWarning(&block)
      if block_given?
        @on_warning = block
        self
      else
        @on_warning
      end
    end

    #This is called when the consumer is stopped.
    #=== Parameters
    #* +reason+ - The reason why the consumer stopped.
    def onStopped(&block)
      if block_given?
        @on_stopped = block
        self
      else
        @on_stopped
      end
    end

    #Once an instance of a StreamConsumer is ready for use, call this to
    #start consuming. Extending classes should implement onStart to handle
    #actually starting.
    #=== Parameters
    #* +auto_reconnect+ - Whether the consumer should automatically reconnect.
    #* +block+ - An optional block to receive incoming interactions.
    def consume(auto_reconnect = true, &block)
      @auto_reconnect = auto_reconnect;

      # Start consuming
      @state          = STATE_STARTING
      onStart do |interaction|
        if interaction.has_key?('status')
          if interaction['status'] == 'error' || interaction['status'] == 'failure'
            onError.call(interaction['message'])
          elsif interaction['status'] == 'warning'
            onWarning.call(interaction['message'])
          else
            # Tick
          end
        else
          if interaction.has_key?('deleted') and interaction['deleted']
            onDeleted.call(interaction) unless onDeleted.nil?
          else
            block.call(interaction) unless block.nil?
          end
        end
      end
    end

    #Called when the consumer should start consuming the stream.
    def onStart()
      abort('onStart method has not been overridden!')
    end

    #This method can be called at any time to *request* that the consumer
    #stop consuming. This method sets the state to STATE_STOPPING and it's
    #up to the consumer implementation to notice that this has changed, stop
    #consuming and call the onStopped method.
    def stop()
      raise InvalidDataError, 'Consumer state must be RUNNING before it can be stopped' unless @state = StreamConsumer::STATE_RUNNING
      @state = StreamConsumer::STATE_STOPPING
    end

    #Default implementation of onStop. It's unlikely that this method will
    #ever be used in isolation, but rather it should be called as the final
    #step in the extending class's implementation.
    #=== Parameters
    #* +reason+ - The reason why the consumer stopped.
    def onStop(reason = '')
      reason = 'Unexpected' unless @state != StreamConsumer::STATE_STOPPING and reason.length == 0
      @state       = StreamConsumer::STATE_STOPPED
      @stop_reason = reason
      onStopped.call(reason) unless onStopped.nil?
    end
  end
end