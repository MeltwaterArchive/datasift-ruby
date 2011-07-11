#
# user.rb - This file contains the User class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The User class represents a user of the API. Applications should start their
# API interactions by creating an instance of this class. Once initialised it
# provides factory methods for all of the functionality in the API.

require 'rest_client'
require 'crack'

module DataSift
	# User class.
	#
	# == Introduction
	#
	# The User class represents a user of the API. Applications should start their
	# API interactions by creating an instance of this class. Once initialised it
	# provides factory methods for all of the functionality in the API.
	#
	class User
		USER_AGENT = 'DataSiftRuby/0.1';
		API_BASE_URL = 'api.datasift.net/';
		STREAM_BASE_URL = 'stream.datasift.net/';

		attr_reader :username, :api_key, :rate_limit, :rate_limit_remaining

		# Constructor. A username and API key are required when constructing an
		# instance of this class.
		# === Parameters
		#
		# * +username+ - The user's username
		# * +api_key+ - The user's API key
		def initialize(username, api_key)
			username.strip!
			api_key.strip!

			raise EInvalidData, 'Please supply valid credentials when creating a User object.' unless username.size > 0 and api_key.size > 0

			@username = username
			@api_key = api_key
			@rate_limit = -1;
			@rate_limit_remaining = -1
		end

		# Creates and returns a definition object.
		# === Parameters
		#
		# * +csdl+ - Optional CSDL string with which to prime the object.
		def createDefinition(csdl = '')
			DataSift::Definition.new(self, csdl, false)
		end

		# Returns the user agent this library should use for all API calls.
		def getUserAgent()
			USER_AGENT
		end

		# Make a call to a DataSift API endpoint.
		# === Parameters
		#
		# * +endpoint+ - The endpoint of the API call.
		# * +params+ - The parameters to be passed along with the request.
		def callAPI(endpoint, params = {})
			params['username'] = @username
			params['api_key'] = @api_key

			# Build the full endpoint URL
			url = 'http://' + API_BASE_URL + endpoint + '.json?' + hash_to_querystring(params)

			begin
				# Make the call
				res = RestClient.get(url, { 'Auth' => @username + ':' + @api_key, 'User-Agent' => getUserAgent() })

				# Parse the JSON response
				retval = Crack::JSON.parse(res)
			rescue RestClient::ExceptionWithResponse => err
				# Get the response
				res = err.response
				# Parse the JSON response
				retval = Crack::JSON.parse(res)

				case err.http_code
				when 401
					# Authentication failure
					raise AccessDeniedError, retval.has_key?('error') ? retval['error'] : 'Authentication failed'
				when 403
					# Check the rate limit
					raise RateLimitExceededError, retval['comment'] if @rate_limit_remaining == 0
					# Rate limit is ok, raise a generic exception
					raise APIError.new(403), retval.has_key?('error') ? retval['error'] : 'Unknown error'
				else
					raise APIError.new(err.http_code), retval.has_key?('error') ? retval['error'] : 'Unknown error'
				end
			end

			# Update the rate limits from the headers
			@rate_limit = -1
			if res.headers[:x_ratelimit_limit]
				@rate_limit = res.headers[:x_ratelimit_limit]
			end

			@rate_limit_remaining = -1
			if res.headers[:x_ratelimit_remaining]
				@rate_limit_remaining = res.headers[:x_ratelimit_remaining]
			end

			retval
		end

		def hash_to_querystring(hash)
			hash.keys.inject('') do |query_string, key|
				query_string << '&' unless key == hash.keys.first
				query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
			end
		end
	end
end
