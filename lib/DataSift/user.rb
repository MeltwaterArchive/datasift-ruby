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
		USER_AGENT = 'DataSiftRuby/0.3.0';
		API_BASE_URL = 'api.datasift.com/';
		STREAM_BASE_URL = 'stream.datasift.com/';

		attr_reader :username, :api_key, :rate_limit, :rate_limit_remaining, :api_client

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

		# Returns a StreamConsumer-derived object for the given hash, for the
		# given type.
		# === Parameters
		#
		# * +type+ - The consumer type for which to construct a consumer.
		# * +hash+ - The hash to be consumed.
		#
		def getConsumer(type = nil, hash = nil, on_interaction = nil, on_stopped = nil)
			StreamConsumer.factory(self, type, Definition.new(self, nil, hash))
		end

		# Returns the usage data for this user. If a hash is provided then a more
		# detailed breakdown using interaction types is retrieved and returned.
		# === Parameters
		#
		# * +period+ - An optional period for which to fetch data ('hour' or 'day')
		def getUsage(period = 'hour')
			if period != 'hour' and period != 'day'
				raise EInvalidData, 'Period must be hour or day'
			end

			params = { 'period' => period }

			callAPI('usage', params)
		end

		# Returns the user agent this library should use for all API calls.
		def getUserAgent()
			USER_AGENT
		end

		# Sets the ApiClient object to use to access the API
		def setApiClient(client)
			@api_client = client
		end

		# Make a call to a DataSift API endpoint.
		# === Parameters
		#
		# * +endpoint+ - The endpoint of the API call.
		# * +params+ - The parameters to be passed along with the request.
		def callAPI(endpoint, params = {})
			if !@api_client
				@api_client = ApiClient.new()
			end

			res = @api_client.call(@username, @api_key, endpoint, params)

			# Set up the return value
			retval = res['data']

			# Update the rate limits from the headers
			@rate_limit = res['rate_limit']
			@rate_limit_remaining = res['rate_limit_remaining']

			case res['response_code']
			when 200
				# Do nothing
			when 401
				# Authentication failure
				raise AccessDeniedError, retval.has_key?('error') ? retval['error'] : 'Authentication failed'
			when 403
				# Check the rate limit
				raise RateLimitExceededError, retval['comment'] if @rate_limit_remaining == 0
				# Rate limit is ok, raise a generic exception
				raise APIError.new(403), retval.has_key?('error') ? retval['error'] : 'Unknown error'
			else
				raise APIError.new(res['http_code']), retval.has_key?('error') ? retval['error'] : 'Unknown error'
			end

			retval
		end
	end
end
