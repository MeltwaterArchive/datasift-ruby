#
# definition.rb - This file contains the Definition class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The User class represents a user of the API. Applications should start their
# API interactions by creating an instance of this class. Once initialised it
# provides factory methods for all of the functionality in the API.

module DataSift

	# Definition class.
	#
	# == Introduction
	#
	# The Definition class represents a stream definition.
	#
	class Definition
		attr_reader :csdl, :total_dpu, :created_at

		# Constructor. A User object is required, and you can optionally supply a
		# default CSDL string.
		# === Parameters
		#
		# * +user+ - The DataSift::User object.
		# * +csdl+ - Optional default CSDL string.
		# * +hash+ - Optional default hash string.
		#
		def initialize(user, csdl = '', hash = false)
			raise InvalidDataError, 'Please supply a valid User object when creating a Definition object.' unless user.is_a? DataSift::User
			@user = user
			clearHash()
			@hash = hash
			self.csdl = csdl
		end

		# CSDL getter
		def csdl
			raise InvalidDataError, 'The CSDL is not available' unless !@csdl.nil?
			@csdl
		end

		# CSDL setter. Strips the incoming string and resets the hash if it's changed.
		def csdl=(csdl)
			if csdl.nil?
				@csdl = nil
			else
				raise InvalidDataError, 'The CSDL must be a string.' unless csdl.is_a? String
				csdl.strip!
				clearHash() unless csdl == @csdl
				@csdl = csdl
			end
		end

		# Hash getter. If the hash has not yet been obtained the CSDL will be
		# compiled first.
		def hash
			if @hash == false
				begin
					compile()
				rescue DataSift::CompileFailedError
					# Ignore
				end
			end

			@hash
		end

		# Reset the hash to false. The effect of this is to mark the definition as
		# requiring compilation.
		def clearHash()
			@csdl = '' unless !@csdl.nil?
			@hash = false
			@total_dpu = false
			@created_at = false
		end

		# Call the DataSift API to compile this definition. On success it will
		# store the returned hash.
		def compile()
			raise InvalidDataError, 'Cannot compile an empty definition.' unless @csdl.length > 0

			begin
				res = @user.callAPI('compile', { 'csdl' => @csdl })

				if res.has_key?('hash')
					@hash = res['hash']
				else
					raise CompileFailedError, 'Compiled successfully but no hash in the response'
				end

				if res.has_key?('dpu')
					@total_dpu = Float(res['dpu'])
				else
					raise CompileFailedError, 'Compiled successfully but no DPU in the response'
				end

				if res.has_key?('created_at')
					@created_at = Date.parse(res['created_at'])
				else
					raise CompileFailedError, 'Compiled successfully but no created_at in the response'
				end
			rescue APIError => err
				clearHash()

				case err.http_code
				when 400
					raise CompileFailedError, err
				else
					raise CompileFailedError, 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.inspect + ']'
				end
			end
		end

		# Call the DataSift API to get the DPU for this definition. Returns an
		# array containing...
		#   detail => The breakdown of running the rule
		#   dpu => The total DPU of the rule
		#
		def getDPUBreakdown()
			raise InvalidDataError, "Cannot get the DPU for an empty definition." unless @csdl.length > 0

			@user.callAPI('dpu', { 'hash' => self.hash })
		end

		# Call the DataSift API to get buffered interactions.
		# === Parameters
		#
		# * +count+ - Optional number of interactions to return (max 200).
		# * +from_id+ - Optional start ID.
		#
		def getBuffered(count = false, from_id = false)
			raise InvalidDataError, "Cannot get buffered interactions for an empty definition." unless @csdl.length > 0

			params = { 'hash' => self.hash }

			if count
				params['count'] = count
			end

			if from_id
				params['interaction_id'] = from_id
			end

			retval = @user.callAPI('stream', params)

			raise APIError, 'No data in the response' unless retval.has_key?('stream')

			retval['stream']
		end

		# Returns a StreamConsumer-derived object for this definition, for the
		# given type.
		# === Parameters
		#
		# * +type+ - The consumer type for which to construct a consumer.
		#
		def getConsumer(type = nil, on_interaction = nil, on_stopped = nil)
			StreamConsumer.factory(@user, type, self)
		end
	end
end
