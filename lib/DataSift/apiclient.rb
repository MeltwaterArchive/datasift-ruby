#
# apiclient.rb - This file contains the ApiClient class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The ApiClient class wraps the functionality that makes calls to the
# DataSift API.

require 'rest_client'
require 'yajl'

module DataSift
	# ApiCLient class.
	#
	# == Introduction
	#
	# The ApiClient class wraps the functionality that makes calls to the
	# DataSift API.
	#
	class ApiClient
		# Make a call to a DataSift API endpoint.
		# === Parameters
		#
		# * +endpoint+ - The endpoint of the API call.
		# * +params+ - The parameters to be passed along with the request.
		# * +username+ - The username for the Auth header
		# * +api_key+ - The API key for the Auth header
		def call(username, api_key, endpoint, params = {}, user_agent = 'DataSiftPHP/0.0', ssl = true)
			# Build the full endpoint URL
			url = 'http' + (ssl ? 's' : '') + '://' + User::API_BASE_URL + endpoint

			retval = {
				'response_code' => 500,
				'data' => { 'error' => 'Unknown error' },
				'rate_limit' => -1,
				'rate_limit_remaining' => -1,
			}

			begin
				# Make the call
				res = RestClient.post(url, params, { 'Auth' => username + ':' + api_key, 'User-Agent' => user_agent })

				# Success
				retval['response_code'] = 200

				# Parse the JSON response
				retval['data'] = Yajl::Parser.parse(res)

				# Rate limit headers
				if (res.headers[:x_ratelimit_limit])
					retval['rate_limit'] = res.headers[:x_ratelimit_limit]
				end

				if (res.headers[:x_ratelimit_remaining])
					retval['rate_limit_remaining'] = res.headers[:x_ratelimit_remaining]
				end
			rescue RestClient::ExceptionWithResponse => err
				# Set the response code
				retval['response_code'] = err.http_code

				# And set the data
				retval['data'] = Yajl::Parser.parse(err.response)
			end

			retval
		end

	private

		def hashToQuerystring(hash)
			hash.keys.inject('') do |query_string, key|
				query_string << '&' unless key == hash.keys.first
				query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
			end
		end
	end
end
