require 'date'

module DataSift
	#The Definition class represents a stream definition.
	class Definition
		#The CSDL for this Definition.
		attr_reader :csdl

		#Constructor. A User object is required, and you can optionally supply a
		#default CSDL string.
		#=== Parameters
		#* +user+ - The DataSift::User object.
		#* +csdl+ - Optional default CSDL string.
		#* +hash+ - Optional default hash string.
		def initialize(user, csdl = '', hash = false)
			raise InvalidDataError, 'Please supply a valid User object when creating a Definition object.' unless user.is_a? DataSift::User
			@user = user
			clearHash()
			@hash = hash
			self.csdl = csdl
			@total_dpu = false
			@created_at = false
		end

		#CSDL getter
		def csdl
			raise InvalidDataError, 'The CSDL is not available' unless !@csdl.nil?
			return @csdl
		end

		#CSDL setter. Strips the incoming string and resets the hash if it's changed.
		def csdl=(csdl)
			if csdl.nil?
				@csdl = nil
			else
				raise InvalidDataError, 'The CSDL must be a string.' unless csdl.is_a? String
				csdl = csdl.strip
				clearHash() unless csdl == @csdl
				@csdl = csdl
			end
		end

		#Total DPU getter.
		def total_dpu
			compile() unless @total_dpu
			return @total_dpu
		end

		#Created at getter.
		def created_at
			compile() unless @created_at
			return @created_at
		end

		#Hash getter. If the hash has not yet been obtained the CSDL will be
		#compiled first.
		def hash
			if @hash == false
				compile()
			end

			return @hash
		end

		#Reset the hash to false. The effect of this is to mark the definition as
		#requiring compilation.
		def clearHash()
			@csdl = '' unless !@csdl.nil?
			@hash = false
			@total_dpu = false
			@created_at = false
		end

		#Call the DataSift API to compile this definition. On success it will
		#store the returned hash.
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
					raise APIError('Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.inspect + ']', err.http_code)
				end
			end
		end

		#Call the DataSift API to validate this definition. On success it will
		#store the details in the response.
		def validate()
			raise InvalidDataError, 'Cannot validate an empty definition.' unless @csdl.length > 0

			begin
				res = @user.callAPI('validate', { 'csdl' => @csdl })

				if res.has_key?('dpu')
					@total_dpu = Float(res['dpu'])
				else
					raise CompileFailedError, 'Validated successfully but no DPU in the response'
				end

				if res.has_key?('created_at')
					@created_at = Date.parse(res['created_at'])
				else
					raise CompileFailedError, 'Validated successfully but no created_at in the response'
				end
			rescue APIError => err
				clearHash()

				case err.http_code
				when 400
					raise CompileFailedError, err
				else
					raise APIError('Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.inspect + ']', err.http_code)
				end
			end
		end

		#Call the DataSift API to get the DPU for this definition. Returns
		#=== Returns
		#A Hash containing...
		#* +detail+ - The breakdown of running the rule
		#* +dpu+ - The total DPU of the rule
		def getDPUBreakdown()
			raise InvalidDataError, "Cannot get the DPU for an empty definition." unless @csdl.length > 0

			@user.callAPI('dpu', { 'hash' => self.hash })
		end

		#Call the DataSift API to get buffered interactions.
		#=== Parameters
		#* +count+ - Optional number of interactions to return (max 200).
		#* +from_id+ - Optional start ID.
		#=== Returns
		#An array of Hashes where each Hash is an interaction.
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

			return retval['stream']
		end

		#Create a Historics query based on this Definition.
		#=== Parameters
		#* +start_date+ - The start date for a new Historics query.
		#* +end_date+ - The end date for a new Historics query.
		#* +sources+ - An array of sources for a new Historics query.
		#* +name+ - The name for a new Historics query.
		#* +sample+ - The sample rate for the new Historics query.
		#=== Returns
		#A Historic object.
		def createHistoric(start_date, end_date, sources, sample, name)
			return Historic.new(@user, hash, start_date, end_date, sources, sample, name)
		end

		#Returns a StreamConsumer-derived object for this definition, for the
		#given type.
		#=== Parameters
		#* +type+ - The consumer type for which to construct a consumer.
		#=== Returns
		#A StreamConsumer-derived object.
		def getConsumer(type = nil, on_interaction = nil, on_stopped = nil)
			StreamConsumer.factory(@user, type, self)
		end
	end
end
