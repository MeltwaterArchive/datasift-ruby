module DataSift
	#The MockApiClient class implements a fake DataSift API interface.
	class MockApiClient
		#Set the response to be returned by the call method
		#=== Parameters
		#* +code+ - The HTTP response code
		#* +data+ - The dictionary that would have come from the response body
		#* +rate_limit+ - The new rate_limit value
		#* +rate_limit_remaining+ - The new rate_limit_remaining value
		def setResponse(code, data, rate_limit, rate_limit_remaining)
			@response = {
				'response_code' => code,
				'data' => data,
				'rate_limit' => rate_limit,
				'rate_limit_remaining' => rate_limit_remaining,
			}
		end

		#Clear the response so we throw an exception if we get called again
		#without a new response being set.
		def clearResponse()
			@response = false
		end

		#Fake a call to a DataSift API endpoint.
		#=== Parameters
		#* +endpoint+ - The endpoint of the API call.
		#* +params+ - The parameters to be passed along with the request.
		#* +username+ - The username for the Auth header
		#* +api_key+ - The API key for the Auth header
		#=== Returns
		#A Hash containing the following as set with the setResponse method...
		#* +response_code+ - The HTTP response code.
		#* +data+ - A Hash containing the response data.
		#* +rate_limit+ - The total API credits you get per hour.
		#* +rate_limit_remaining+ - The number of API credits you have remaining for this hour.
		def call(username, api_key, endpoint, params = {}, user_agent = 'DataSiftRuby/0.0')
			if !@response
				raise StandardError, 'Expected response not set in mock object'
			end
			return @response
		end
	end
end
