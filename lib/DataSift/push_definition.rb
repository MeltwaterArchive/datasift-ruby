module DataSift
	#The PushDefinition class represents a stream definition.
	class PushDefinition
		#Output parameter names are prefixed with this string before being sent to
		#the API.
		OUTPUT_PARAMS_PREFIX = 'output_params.'

		#The initial status for subscriptions to this endpoint.
		attr_accessor :initial_status
		#The output type for this Push definition.
		attr_accessor :output_type
		#The output parameters for this Push definition.
		attr_accessor :output_params

		#Constructor. A User object is required.
		#=== Parameters
		#* +user+ - The DataSift::User object.
		def initialize(user)
			raise InvalidDataError, 'Please supply a valid User object when creating a Definition object.' unless user.is_a? DataSift::User
			@user = user
			@initial_status = ''
			@output_type = ''
			@output_params = {}
		end

		#Validate the output type and parameters with the DataSift API.
		def validate()
			begin
				params = { 'output_type' => @output_type }
				@output_params.each { |k,v| params[OUTPUT_PARAMS_PREFIX + k] = v }
				@user.callAPI('push/validate', params)
			rescue APIError => err
				case err.http_code
				when 400
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#Subscribe this endpoint to a Definition.
		#=== Parameters
		#* +definition+ - The Definition object.
		#* +name+ - A name for this subscription.
		#=== Returns
		#A PushSubscription object.
		def subscribeDefinition(definition, name)
			return subscribeStreamHash(definition.hash, name)
		end

		#Subscribe this endpoint to a stream hash.
		#=== Parameters
		#* +hash+ - The stream hash.
		#* +name+ - A name for this subscription.
		#=== Returns
		#A PushSubscription object.
		def subscribeStreamHash(hash, name)
			return subscribe('hash', hash, name)
		end

		#Subscribe this endpoint to a Historics query.
		#=== Parameters
		#* +historic+ - The Historic object.
		#* +name+ - A name for this subscription.
		#=== Returns
		#A PushSubscription object.
		def subscribeHistoric(historic, name)
			return subscribeHistoricPlaybackId(historic.hash, name)
		end

		#Subscribe this endpoint to a Historics playback ID.
		#=== Parameters
		#* +playback_id+ - The playback ID.
		#* +name+ - A name for this subscription.
		#=== Returns
		#A PushSubscription object.
		def subscribeHistoricPlaybackId(playback_id, name)
			return subscribe('playback_id', playback_id, name)
		end

		#Subscribe this endpoint to a hash.
		#=== Parameters
		#* +hash_type+ - The hash type.
		#* +hash+ - The hash.
		#* +name+ - A name for this subscription.
		#=== Returns
		#A PushSubscription object.
		def subscribe(hash_type, hash, name)
			begin
				# API call parameters
				params = {
					'name'        => name,
					hash_type     => hash,
					'output_type' => @output_type
				}
				# Output parameters with prefix
				@output_params.each { |k,v| params[OUTPUT_PARAMS_PREFIX + k] = v }
				# Add the initial status if it's not empty
				params['initial_status'] = @initial_status unless @initial_status == ''

				# Call the API and create a new PushSubscription from the returned
				# object
				return PushSubscription.new(@user, @user.callAPI('push/create', params))
			rescue APIError => err
				case err.http_code
				when 400
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end
	end
end
