#This is the official DataSift client library for Ruby.
module DataSift
	#The User class represents a user of the API. Applications should start their
	#API interactions by creating an instance of this class. Once initialised it
	#provides factory methods for all of the functionality in the API.
	class User
		#The user agent to pass through with all HTTP requests.
		USER_AGENT = 'DataSiftRuby/' + File.open(File.dirname(File.dirname(File.dirname(__FILE__))) + '/VERSION').first;
		#The base URL for API requests.
		API_BASE_URL = 'api.datasift.com/';
		#The base URL for streams.
		STREAM_BASE_URL = 'stream.datasift.com/';

		#The User's DataSift username.
		attr_reader :username
		#The User's DataSift API key.
		attr_reader :api_key
		#The User's total number of available hourly API credits. This is not
		#populated until an API request is made.
		attr_reader :rate_limit
		#The User's API credits remaining. This is not populated until an API
		#request is made.
		attr_reader :rate_limit_remaining
		#The APIClient class to use when making API requests.
		attr_reader :api_client
		#True if streaming connections should use SSL.
		attr_reader :use_ssl

		#Constructor. A username and API key are required when constructing an
		#instance of this class.
		#=== Parameters
		#* +username+ - The User's DataSift username
		#* +api_key+ - The User's DataSift API key
		def initialize(username, api_key, use_ssl = true)
			username.strip!
			api_key.strip!

			raise EInvalidData, 'Please supply valid credentials when creating a User object.' unless username.size > 0 and api_key.size > 0

			@username = username
			@api_key = api_key
			@rate_limit = -1;
			@rate_limit_remaining = -1
			@use_ssl = use_ssl
		end

		#Creates and returns a definition object.
		#=== Parameters
		#* +csdl+ - Optional CSDL string with which to prime the object.
		#=== Returns
		#A Definition object.
		def createDefinition(csdl = '')
			DataSift::Definition.new(self, csdl, false)
		end

		#Create a Historics query based on this Definition.
		#=== Parameters
		#* +hash+ - The stream hash for a new Historics query.
		#* +start_date+ - The start date for a new Historics query.
		#* +end_date+ - The end date for a new Historics query.
		#* +sources+ - An array of sources for a new Historics query.
		#* +name+ - The name for a new Historics query.
		#* +sample+ - The sample rate for the new Historics query.
		#=== Returns
		#A Historic object.
		def createHistoric(hash, start_date, end_date, sources, sample, name)
			return Historic.new(self, hash, start_date, end_date, sources, sample, name)
		end

		#Get a Historics query from the API.
		#=== Parameters
		#* +playback_id+ - The playback ID of the Historics query to retrieve.
		#=== Returns
		#A Historic object.
		def getHistoric(playback_id)
			return Historic.new(self, playback_id)
		end

		# Get a list of Historics queries in your account.
		#=== Parameters
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of Historics queries in your account.
		#* +historics+ - An array of Hashes where each Hash is a Historics query.
		def listHistorics(page = 1, per_page = 20)
			return Historic::list(self, page, per_page)
		end

		#Create a new PushDefinition object for this user.
		#=== Returns
		#A PushDefinition object.
		def createPushDefinition()
			return PushDefinition.new(self)
		end

		#Get an existing PushSubscription from the API.
		#=== Parameters
		#* +subscription_id+ - The ID of the subscription to fetch.
		#=== Returns
		#A PushSubscription object.
		def getPushSubscription(subscription_id)
			return PushSubscription.get(self, subscription_id)
		end

		#Get the log entries for all push subscription or the given subscription.
		#=== Parameters
		#* +subscription_id+ - Optional subscription ID.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of matching log entries.
		#* +log_entries+ - An array of Hashes where each Hash is a log entry.
		def getPushSubscriptionLog(subscription_id = false)
			if subscription_id
				return getPushSubscription(subscription_id).getLog()
			else
				return PushSubscription.getLogs(self)
			end
		end

		#Get a page of Push subscriptions in the given user's account, where each
		#page contains up to per_page items. Results will be ordered according to
		#the supplied ordering parameters.
		#=== Parameters
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#* +order_by+ - The field by which to order the results.
		#* +order_dir+ - Ascending or descending.
		#* +include_finished+ - True to include subscriptions against finished Historics queries.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of matching Push subscriptions in your account.
		#* +subscriptions+ - An array of Hashes where each Hash is a Push subscription.
		def listPushSubscriptions(page = 1, per_page = 20, order_by = PushSubscription::ORDERBY_CREATED_AT, order_dir = PushSubscription::ORDERDIR_ASC, include_finished = false)
			return PushSubscription.list(self, page, per_page, order_by, order_dir, include_finished)
		end

		#Get a page of Push subscriptions in the given user's account, where each
		#page contains up to per_page items. Results will be ordered according to
		#the supplied ordering parameters.
		#=== Parameters
		#* +hash+ - The stream hash.
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#* +order_by+ - The field by which to order the results.
		#* +order_dir+ - Ascending or descending.
		#* +include_finished+ - True to include subscriptions against finished Historics queries.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of matching Push subscriptions in your account.
		#* +subscriptions+ - An array of Hashes where each Hash is a Push subscription.
		def listPushSubscriptionsToStreamHash(hash, page = 1, per_page = 20, order_by = PushSubscription::ORDERBY_CREATED_AT, order_dir = PushSubscription::ORDERDIR_ASC, include_finished = false)
			return PushSubscription.listByStreamHash(self, hash, page, per_page, order_by, order_dir)
		end

		#Get a page of Push subscriptions in the given user's account, where each
		#page contains up to per_page items. Results will be ordered according to
		#the supplied ordering parameters.
		#=== Parameters
		#* +hash+ - The stream hash.
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#* +order_by+ - The field by which to order the results.
		#* +order_dir+ - Ascending or descending.
		#* +include_finished+ - True to include subscriptions against finished Historics queries.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of matching Push subscriptions in your account.
		#* +subscriptions+ - An array of Hashes where each Hash is a Push subscription.
		def listPushSubscriptionsToPlaybackId(playback_id, page = 1, per_page = 20, order_by = PushSubscription::ORDERBY_CREATED_AT, order_dir = PushSubscription::ORDERDIR_ASC, include_finished = false)
			return PushSubscription.listByPlaybackId(self, playback_id, page, per_page, order_by, order_dir)
		end

		#Returns a StreamConsumer-derived object for the given hash, for the
		#given type.
		#=== Parameters
		#* +type+ - The consumer type for which to construct a consumer.
		#* +hash+ - The hash to be consumed.
		#=== Returns
		#A StreamConsumer-derived object.
		def getConsumer(type = nil, hash = nil, on_interaction = nil, on_stopped = nil)
			StreamConsumer.factory(self, type, Definition.new(self, nil, hash))
		end

		#Returns the account balance information for this user.
		#=== Returns
		#A Hash containing the balance information.
		def getBalance
			return callAPI('balance')['balance']
		end

		#Returns the usage data for this user. If a hash is provided then a more
		#detailed breakdown using interaction types is retrieved and returned.
		#=== Parameters
		#* +period+ - An optional period for which to fetch data ('hour' or 'day')
		#=== Returns
		#A Hash containing the usage information.
		def getUsage(period = 'hour')
			params = { 'period' => period }

			return callAPI('usage', params)
		end

		#Returns the user agent this library should use for all API calls.
		#=== Returns
		#The user agent string.
		def getUserAgent()
			return USER_AGENT
		end

		#Sets the ApiClient object to use to access the API
		#=== Parameters
		#* +client+ - The API client object to be used.
		def setApiClient(client)
			@api_client = client
		end

		#Sets whether to use SSL for API and stream communication.
		#=== Parameters
		#* +use_ssl+ - Pass true to use SSL.
		def enableSSL(use_ssl = true)
			@use_ssl = use_ssl
		end

		#Make a call to a DataSift API endpoint.
		#=== Parameters
		#* +endpoint+ - The endpoint of the API call.
		#* +params+ - A Hash of parameters to be passed along with the request.
		#=== Returns
		#A Hash containing the response data.
		def callAPI(endpoint, params = {})
			if !@api_client
				@api_client = ApiClient.new()
			end

			res = @api_client.call(@username, @api_key, endpoint, params, getUserAgent())

			# Set up the return value
			retval = res['data']

			# Update the rate limits from the headers
			@rate_limit = res['rate_limit']
			@rate_limit_remaining = res['rate_limit_remaining']

			case res['response_code']
			when 200
			when 201
			when 204
				# Do nothing
			when 401
				# Authentication failure
				raise AccessDeniedError, retval.has_key?('error') ? retval['error'] : 'Authentication failed'
			when 403
				# Check the rate limit
				raise RateLimitExceededError, retval['comment'] if @rate_limit_remaining == 0
				# Rate limit is ok, raise a generic exception
				raise APIError.new(res['response_code']), retval.has_key?('error') ? retval['error'] : 'Unknown error'
			else
				raise APIError.new(res['response_code']), retval.has_key?('error') ? retval['error'] : 'Unknown error'
			end

			return retval
		end
	end
end
