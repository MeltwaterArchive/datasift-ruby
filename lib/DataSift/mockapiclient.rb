#
# mockapiclient.rb - This file contains the MockApiClient class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The MockApiClient class implements a fake DataSift API interface.

module DataSift
	# MockApiCLient class.
	#
	# == Introduction
	#
	# The ApiClient class implements a fake DataSift API interface.
	#
	class MockApiClient
		# Set the response to be returned by the call method
		# === Parameters
		#
		# * +code+ - The HTTP response code
		# * +data+ - The dictionary that would have come from the response body
		# * +rate_limit+ - The new rate_limit value
		# * +rate_limit_remaining+ - The new rate_limit_remaining value
		def setResponse(code, data, rate_limit, rate_limit_remaining)
			@response = {
				'response_code' => code,
				'data' => data,
				'rate_limit' => rate_limit,
				'rate_limit_remaining' => rate_limit_remaining,
			}
		end

		# Clear the response so we throw an exception if we get called again
		# without a new response being set.
		#
		def clearResponse()
			@response = false
		end

		# Fake a call to a DataSift API endpoint.
		# === Parameters
		#
		# * +endpoint+ - The endpoint of the API call.
		# * +params+ - The parameters to be passed along with the request.
		# * +username+ - The username for the Auth header
		# * +api_key+ - The API key for the Auth header
		def call(username, api_key, endpoint, params = {}, user_agent = 'DataSiftPHP/0.0')
			if !@response
				raise StandardError, 'Expected response not set in mock object'
			end
			@response
		end
	end
end
