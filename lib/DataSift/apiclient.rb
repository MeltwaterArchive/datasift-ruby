require 'rest_client'
require 'yajl'

module DataSift
	#The ApiClient class wraps the functionality that makes calls to the
	#DataSift API.
	class ApiClient
		#Make a call to a DataSift API endpoint.
		#=== Parameters
		#* +user+ - The DataSift User object.
		#* +endpoint+ - The endpoint of the API call.
		#* +params+ - The parameters to be passed along with the request.
		#=== Returns
		#A Hash contatining...
		#* +response_code+ - The HTTP response code.
		#* +data+ - A Hash containing the response data.
		#* +rate_limit+ - The total API credits you get per hour.
		#* +rate_limit_remaining+ - The number of API credits you have remaining for this hour.
		def call(user, endpoint, params = {}, user_agent = User::USER_AGENT)
			# Build the full endpoint URL
			url = 'http' + (user.use_ssl ? 's' : '') + '://' + User::API_BASE_URL + endpoint

			retval = {
				'response_code' => 500,
				'data' => { 'error' => 'Unknown error' },
				'rate_limit' => -1,
				'rate_limit_remaining' => -1,
			}

			begin
				# Make the call
				res = RestClient.post(url, params, { 'Auth' => user.username + ':' + user.api_key, 'User-Agent' => user_agent })

				# Success
				retval['response_code'] = res.code

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

			return retval
		end

	private

		#Convert a Hash to an HTTP query string.
		#=== Parameters
		#* +hash+ - The Hash to convert.
		#=== Returns
		#A string containing the equivalent query string.
		def hashToQuerystring(hash)
			hash.keys.inject('') do |query_string, key|
				query_string << '&' unless key == hash.keys.first
				query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
			end
		end
	end
end
