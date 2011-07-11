#
# stream_consumer.rb - This file contains the StreamConsumer class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The StreamConsumer class is base class for various stream consumers.

module DataSift

	# StreamConsumer class.
	#
	class StreamConsumer
		TYPE_HTTP = 'HTTP'

		STATE_STOPPED = 0
		STATE_STARTING = 1
		STATE_RUNNING = 2
		STATE_STOPPING = 3

		# Factory function. Creates a StreamConsumer-derived object for the given
		# type.
		# === Parameters
		#
		# * +type+ - Use the TYPE_ constants
		# * +definition+ - CSDL string or a Definition object.
		#
		def self.factory(user, type, definition)
			type ||= TYPE_HTTP
			@klass = Module.const_get('DataSift').const_get('StreamConsumer_' + type)
			@klass.new(user, definition)
		end

		attr_accessor :auto_reconnect
		attr_reader :state, :stop_reason

		# Constructor. Do not use this directly, use the factory method instead.
		# === Parameters
		#
		# * +user+ - The user this consumer will run as.
		# * +definition+ - CSDL string or a Definition object.
		#
		def initialize(user, definition)
			raise InvalidDataError, 'Please supply a valid User object when creating a Definition object.' unless user.is_a? DataSift::User

			if definition.is_a? String
				@definition = user.createDefinition(definition)
			elsif definition.is_a? Definition
				@definition = definition
			else
				raise InvalidDataError, 'The definition must be a CSDL string or a DataSift_Definition object'
			end

			@user = user
			@auto_reconnect = true
			@stop_reason = 'Unknown reason'
			@state = STATE_STOPPED

			# Compile the definition to ensure it's valid for use
			@definition.compile()
		end

		# This is called when the consumer is stopped.
		# === Parameters
		#
		# * +reason+ - The reason why the consumer stopped.
		#
		def onStopped(&block)
			if block_given?
				@on_stopped = block
				self
			else
				@on_stopped
			end
		end

		# Once an instance of a StreamConsumer is ready for use, call this to
		# start consuming. Extending classes should implement onStart to handle
		# actually starting.
		# === Parameters
		#
		# * +auto_reconnect+ - Whether the consumer should automatically reconnect.
		# * +block+ - An optional block to receive incoming interactions.
		#
		def consume(auto_reconnect = true, &block)
			@auto_reconnect = auto_reconnect;

			# Start consuming
			@state = STATE_STARTING
			onStart(&block)
		end

		# Called when the consumer should start consuming the stream.
		#
		def onStart()
			puts 'onStart method has not been overridden!'
		end

		# This method can be called at any time to *request* that the consumer
		# stop consuming. This method sets the state to STATE_STOPPING and it's
		# up to the consumer implementation to notice that this has changed, stop
		# consuming and call the onStopped method.
		#
		def stop()
			raise InvalidDataError, 'Consumer state must be RUNNING before it can be stopped' unless @state = StreamConsumer::STATE_RUNNING
			@state = StreamConsumer::STATE_STOPPING
		end

		# Default implementation of onStop. It's unlikely that this method will
		# ever be used in isolation, but rather it should be called as the final
		# step in the extending class's implementation.
		# === Parameters
		#
		# * +reason+ - The reason why the consumer stopped.
		#
		def onStop(reason = '')
			reason = 'Unexpected' unless @state != StreamConsumer::STATE_STOPPING and reason.length == 0
			@state = StreamConsumer::STATE_STOPPED
			@stop_reason = reason
			onStopped.call(reason) unless onStopped.nil?
		end
	end
end
