#
# definition.rb - This file contains the Definition class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The Definition class represents a stream definition.

module DataSift

	# Definition class.
	#
	# == Introduction
	#
	# The Definition class represents a stream definition.
	#
	class Definition
		attr_reader :csdl, :total_cost, :created_at

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

		# CSDL setter. Strips the incoming string and resets the hash if it's changed.
		def csdl=(csdl)
			raise InvalidDataError, 'The CSDL must be a string.' unless csdl.is_a? String
			csdl.strip!
			clearHash() unless csdl == @csdl
			@csdl = csdl
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
			@hash = false
			@total_cost = false
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

				if res.has_key?('cost')
					@total_cost = Integer(res['cost'])
				else
					raise CompileFailedError, 'Compiled successfully but no cost in the response'
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
					raise CompileFailedError, 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err + ']'
				end
			end
		end

		# Call the DataSift API to get the cost for this definition. Returns an
		# array containing...
		#   costs => The breakdown of running the rule
		#   tags => The tags associated with the rule
		#   total => The total cost of the rule
		#
		def getCostBreakdown()
			raise InvalidDataError, "Cannot get the cost for an empty definition." unless @csdl.length > 0

			@user.callAPI('cost', { 'hash' => self.hash })
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

		# Returns the usage for this definition.
		# === Parameters
		#
		# * +start_time+ - An optional timestamp to specify the start of the
		#                  period in which we're interested.
		# * +end_time+ - An optional timestamp to specify the end of the period
		#                in which we're interested.
		def getUsage(start_time = -1, end_time = -1)
			raise InvalidDataError, "Cannot get the usage for an empty definition." unless @csdl.length > 0

			@user.getUsage(start_time, end_time, self.hash)
		end
	end
end
