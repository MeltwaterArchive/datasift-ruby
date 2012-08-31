require 'date'

module DataSift
	#The Historic class represents a Historics query.
	class Historic
		#Get a list of Historics queries in your account.
		#=== Parameters
		#* +user+ - The user object making the request.
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of Historics queries in your account.
		#* +historics+ - An array of Hashes where each Hash is a Historics query.
		def self.list(user, page = 1, per_page = 20)
			begin
				res = user.callAPI(
					'historics/get', {
						'page' => page,
						'max' => per_page
					})

				retval = { 'count' => res['count'], 'historics' => [] }
				for historic in res['data']
					retval['historics'].push(new(user, historic))
				end
				retval
			rescue APIError => err
				case err.http_code
				when 400
					# Missing or invalid parameters
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#The ID of this Historics query.
		attr_reader :playback_id
		#The stream hash which this Historics query is executing.
		attr_reader :stream_hash
		#The friendly name for this Historics query.
		attr_reader :name
		#The start date for this Historics query.
		attr_reader :start_date
		#The end date for this Historics query.
		attr_reader :end_date
		#The date/time when this Historics query was created.
		attr_reader :created_at
		#The current status of this Historics query.
		attr_reader :status
		#The current progress in percent of this Historics query.
		attr_reader :progress
		#The data sources for which this Historics query is looking.
		attr_reader :sources
		#The sample percentage that this Historics query will match.
		attr_reader :sample
		#The DPU cost of running this Historics query.
		attr_reader :dpus
		#The data availability for this Historics query.
		attr_reader :volume_info
		#True if this Historics query has been deleted.
		attr_reader :is_deleted

		#Constructor. Pass all parameters to create a new Historics query, or provide a User object and a playback_id as the hash parameter to load an existing query from the API.
		#=== Parameters
		#* +user+ - The DataSift::User object.
		#* +hash+ - Either a stream_hash, an array containing the Historics query data or a playback ID.
		#* +start_date+ - The start date for a new Historics query.
		#* +end_date+ - The end date for a new Historics query.
		#* +sources+ - An array of sources for a new Historics query.
		#* +name+ - The name for a new Historics query.
		#* +sample+ - The sample rate for the new Historics query.
		def initialize(user, hash, start_date = false, end_date = false, sources = false, sample = false, name = false)
			raise InvalidDataError, 'Please supply a valid User object when creating a Historic object.' unless user.is_a? DataSift::User
			@user = user

			if not start_date
				if hash.kind_of?(Hash)
					# Initialising from an array
					@playback_id = hash['id']
					initFromArray(hash)
				else
					# Fetching from the API
					@playback_id = hash
					reloadData()
				end
			else
				# Creating a new Historic query, make sure we have all the parameters
				raise InvalidDataError,
					'Please supply all parameters when creating a new Historics query' unless
						start_date != false and end_date != false and sources != false and
						name != false and sample != false

				# Convert and validate the parameters as required
				hash = hash.hash if hash.is_a? DataSift::Definition
				start_date = DateTime.strftime(start_date, '%s') unless start_date.is_a? Date
				end_date = DateTime.strptime(end_date, '%s') unless end_date.is_a? Date
				raise InvalidDataError, 'Please supply an array of sources' unless sources.kind_of?(Array)

				@playback_id  = false
				@stream_hash  = hash
				@start_date   = start_date
				@end_date     = end_date
				@sources      = sources
				@name         = name
				@sample       = sample
				@progress     = 0
				@dpus         = false
				@availability = {}
				@volume_info  = {}
				@is_deleted   = false
			end
		end

		#Reload the data for this object from the API.
		def reloadData()
			#Can't do this if we've been deleted
			raise InvalidDataError, 'Cannot reload the data for a deleted Historics query' unless not @is_deleted

			#Can't do this without a playback ID
			raise InvalidDataError, 'Cannot reload the data with a Historics query with no playback ID' unless @playback_id

			begin
				initFromArray(@user.callAPI('historics/get', { 'id' => @playback_id }))
			rescue APIError => err
				case err.http_code
				when 400
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#Initialise this obejct from the data in a Hash.
		#=== Parameters
		#* +data+ - The Hash containing the data.
		def initFromArray(data)
			raise APIError, 'No playback ID in the response' unless data.has_key?('id')
			raise APIError, 'Incorrect playback ID in the response' unless not @playback_id or data['id'] == @playback_id
			@playback_id = data['id']

			raise APIError, 'No definition hash in the response' unless data.has_key?('definition_id')
			@stream_hash = data['definition_id']

			raise APIError, 'No name in the response' unless data.has_key?('name')
			@name = data['name']

			raise APIError, 'No start timestamp in the response' unless data.has_key?('start')
			@start_date = DateTime.strptime(String(data['start']), '%s')

			raise APIError, 'No end timestamp in the response' unless data.has_key?('end')
			@end_date = DateTime.strptime(String(data['end']), '%s')

			raise APIError, 'No created at timstamp in the response' unless data.has_key?('created_at')
			@created_at = DateTime.strptime(String(data['created_at']), '%s')

			raise APIError, 'No status in the response' unless data.has_key?('status')
			@status = data['status']

			raise APIError, 'No progress in the response' unless data.has_key?('progress')
			@progress = data['progress']

			raise APIError, 'No sources in the response' unless data.has_key?('sources')
			@sources = data['sources']

			raise APIError, 'No sample in the response' unless data.has_key?('sample')
			@sample = data['sample']

			raise APIError, 'No volume info in the response' unless data.has_key?('volume_info')
			@volume_info = data['volume_info']

			@is_deleted = (@status == 'deleted')

			return true
		end

		#Getter for the playback ID. If the Historics query has not yet been
		#prepared that will be done automagically to obtain the playback ID.
		def hash
			if @playback_id == false
				prepare()
			end

			@playback_id
		end

		#Name setter. Updates via the API if this Historics query has already
		#been prepared.
		def name=(new_name)
			raise InvalidDataError, 'Cannot set the name of a deleted Historics query' unless not @is_deleted

			if not @playback_id
				@name = new_name
			else
				@user.callAPI('historics/update', { 'id' => @playback_id, 'name' => new_name })
				reloadData()
			end
		end

		#Call the DataSift API to prepare this Historics query
		def prepare()
			raise InvalidDataError, 'Cannot prepare a deleted Historics query' unless not @is_deleted
			raise InvalidDataError, 'This Historics query has already been prepared' unless not @playback_id

			begin
				res = @user.callAPI(
					'historics/prepare', {
						'hash' => @stream_hash,
						'start' => Integer(@start_date.strftime('%s')),
						'end' => Integer(@end_date.strftime('%s')),
						'name' => @name,
						'sources' => @sources.join(',')
					})

				raise InvalidDataError, 'Prepared successfully but no playback ID in the response' unless res.has_key?('id')
				@playback_id = res['id']

				raise InvalidDataError, 'Prepared successfully but no DPU cost in the response' unless res.has_key?('dpus')
				@dpus = res['dpus']

				raise InvalidDataError, 'Prepared successfully but no availability in the response' unless res.has_key?('availability')
				@availability = res['availability']
			rescue APIError => err
				case err.http_code
				when 400
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end

			# Reload the data so we get the created_at date, initial status and the rest.
			reloadData()
		end

		#Start this Historics query.
		def start()
			raise InvalidDataError, 'Cannot start a deleted Historics query' unless not @is_deleted
			raise InvalidDataError, 'Cannot start a Historics query that hasn\'t been prepared' unless @playback_id

			begin
				res = @user.callAPI('historics/start', { 'id' => @playback_id })
			rescue APIError => err
				case err.http_code
				when 400
					# Missing or invalid parameters
					raise InvalidDataError, err
				when 404
					# Historics query not found
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#Stop this Historics query.
		def stop()
			raise InvalidDataError, 'Cannot stop a deleted Historics query' unless not @is_deleted
			raise InvalidDataError, 'Cannot stop a Historics query that hasn\'t been prepared' unless @playback_id

			begin
				res = @user.callAPI('historics/stop', { 'id' => @playback_id })
			rescue APIError => err
				case err.http_code
				when 400
					# Missing or invalid parameters
					raise InvalidDataError, err
				when 404
					# Historics query not found
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#Delete this Historics query.
		def delete()
			raise InvalidDataError, 'Cannot delete a deleted Historics query' unless not @is_deleted
			raise InvalidDataError, 'Cannot delete a Historics query that hasn\'t been prepared' unless @playback_id

			begin
				@user.callAPI('historics/delete', { 'id' => @playback_id })
				@is_deleted = true
			rescue APIError => err
				case err.http_code
				when 400
					# Missing or invalid parameters
					raise InvalidDataError, err
				when 404
					# Historics query not found
					raise InvalidDataError, err
				else
					raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
				end
			end
		end

		#Get a page of Push subscriptions for this Historics query, where each
		#page contains up to per_page items. Results will be returned in the
		#order requested.
		#=== Parameters
		#* +page+ - The page number to get.
		#* +per_page+ - The number of items per page.
		#* +order_by+ - The field by which to order the results.
		#* +order_dir+ - Ascending or descending.
		#* +include_finished+ - True to include subscriptions against finished Historics queries.
		#=== Returns
		#A Hash containing...
		#* +count+ - The total number of Push subscriptions in your account.
		#* +subscriptions+ - An array of Hashes where each Hash is a Push subscription.
		def getPushSubscriptions(page = 1, per_page = 20, order_by = PushSubscription::ORDERBY_CREATED_AT, order_dir = PushSubscription::ORDERDIR_ASC)
			return PushSubscription.list(@user, page, per_page, order_by, order_dir, true, 'playback_id', @playback_id)
		end
	end

end
