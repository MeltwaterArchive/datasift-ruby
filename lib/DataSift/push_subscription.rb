#
# definition.rb - This file contains the Definition class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The User class represents a user of the API. Applications should start their
# API interactions by creating an instance of this class. Once initialised it
# provides factory methods for all of the functionality in the API.

module DataSift
	# PushDefinition class.
	#
	# == Introduction
	#
	# The Definition class represents a stream definition.
	#
	class PushSubscription < PushDefinition
		# Hash type constants.
		HASH_TYPE_STREAM   = 'stream'
		HASH_TYPE_HISTORIC = 'historic'

		# Status constants.
		STATUS_ACTIVE    = 'active'
		STATUS_PAUSED    = 'paused'
		STATUS_STOPPED   = 'stopped'
		STATUS_FINISHING = 'finishing'
		STATUS_FINISHED  = 'finished'
		STATUS_FAILED    = 'failed'
		STATUS_DELETED   = 'deleted'

		# Order by constants.
		ORDERBY_ID           = 'id'
		ORDERBY_CREATED_AT   = 'created_at'
		ORDERBY_REQUEST_TIME = 'request_time'

		# Order direction constants.
		ORDERDIR_ASC  = 'asc'
		ORDERDIR_DESC = 'desc'

		# Get a single Push subscription by ID.
		# === Parameters
		#
		# * +id+ - The subscription ID.
		#
		def self.get(user, id)
			return new(user, user.callAPI('push/get', { 'id' => id }))
		end

		# Get a page of Push subscriptions in the given user's account, where each
		# page contains up to per_page items. Results will be ordered according to
		# the supplied ordering parameters.
		# === Parameters
		#
		# * +user+ - The user object making the request.
		# * +page+ - The page number to get.
		# * +per_page+ - The number of items per page.
		# * +order_by+ - The field by which to order the results.
		# * +order_dir+ - Ascending or descending.
		# * +include_finished+ - True to include subscriptions against finished Historics queries.
		# * +hash_type+ - Optional hash type to look for (hash is also required)
		# * +hash* - Optional hash to look for (hash_type is also required)
		#
		def self.list(user, page = 1, per_page = 20, order_by = ORDERBY_CREATED_AT, order_dir = ORDERDIR_ASC, include_finished = false, hash_type = false, hash = false)
			begin
				raise InvalidDataError, 'The specified page number is invalid' unless page >= 1
				raise InvalidDataError, 'The specified per_page value is invalid' unless per_page >= 1

				params = {
					'page'      => page,
					'per_page'  => per_page,
					'order_by'  => order_by,
					'order_dir' => order_dir
				}

				if hash_type and hash
					params[hash_type] = hash
				end

				if include_finished
					params['include_finished'] = 1
				end

				res = user.callAPI('push/get', params)

				retval = { 'count' => res['count'], 'subscriptions' => [] }
				for subscription in res['subscriptions']
					retval['subscriptions'].push(new(user, subscription))
				end
				return retval
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

		# Get a page of Push subscriptions for the given stream hash, where each
		# page contains up to per_page items. Results will be ordered according to
		# the supplied ordering parameters.
		# === Parameters
		#
		# * +user+ - The user object making the request.
		# * +hash+ - The stream hash.
		# * +page+ - The page number to get.
		# * +per_page+ - The number of items per page.
		# * +order_by+ - The field by which to order the results.
		# * +order_dir+ - Ascending or descending.
		# * +include_finished+ - True to include subscriptions against finished Historics queries.
		#
		def self.listByStreamHash(user, hash, page = 1, per_page = 20, order_by = ORDERBY_CREATED_AT, order_dir = ORDERDIR_ASC)
			return self.list(user, page, per_page, order_by, order_dir, false, 'hash', hash)
		end

		# Get a page of Push subscriptions for the given stream hash, where each
		# page contains up to per_page items. Results will be ordered according to
		# the supplied ordering parameters.
		# === Parameters
		#
		# * +user+ - The user object making the request.
		# * +playback_id+ - The playback ID.
		# * +page+ - The page number to get.
		# * +per_page+ - The number of items per page.
		# * +order_by+ - The field by which to order the results.
		# * +order_dir+ - Ascending or descending.
		# * +include_finished+ - True to include subscriptions against finished Historics queries.
		#
		def self.listByPlaybackId(user, playback_id, page = 1, per_page = 20, order_by = ORDERBY_CREATED_AT, order_dir = ORDERDIR_ASC, include_finished = false)
			return self.list(user, page, per_page, order_by, order_dir, include_finished, 'playback_id', playback_id)
		end

		# Page through recent Push subscription log entries, specifying the sort
		# order.
		# === Parameters
		#
		# * +user+ - The user object making the request.
		# * +page+ - The page number to get.
		# * +per_page+ - The number of items per page.
		# * +order_by+ - The field by which to order the results.
		# * +order_dir+ - Ascending or descending.
		# * +id+ - Optional subscription ID.
		#
		def self.getLogs(user, page = 1, per_page = 20, order_by = ORDERBY_REQUEST_TIME, order_dir = ORDERDIR_DESC, id = false)
			begin
				raise InvalidDataError, 'The specified page number is invalid' unless page >= 1
				raise InvalidDataError, 'The specified per_page value is invalid' unless per_page >= 1

				params = {
					'page'      => page,
					'per_page'  => per_page,
					'order_by'  => order_by,
					'order_dir' => order_dir
				}

				if id != false
					params['id'] = id
				end

				return user.callAPI('push/log', params)
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

		attr_reader :id, :created_at, :name, :status, :hash, :hash_type
		attr_reader :last_request, :last_success, :is_deleted

		# Constructor. A User object is required, along with a Hash containing the
		# subscription data.
		# === Parameters
		#
		# * +user+ - The DataSift::User object.
		# * +data+ - The Hash containing the subscription data.
		#
		def initialize(user, data)
			super(user)
			init(data)
		end

		# Extract the subscription data from a Hash.
		# === Parameters
		#
		# * +data+ - The Hash containing the subscription data.
		#
		def init(data)
			raise InvalidDataError, 'No id found' unless data.has_key?('id')
			@id = data['id']

			raise InvalidDataError, 'No name found' unless data.has_key?('name')
			@name = data['name']

			raise InvalidDataError, 'No created_at found' unless data.has_key?('created_at')
			@created_at = DateTime.strptime(String(data['created_at']), '%s') unless data['created_at'].nil?

			raise InvalidDataError, 'No status found' unless data.has_key?('status')
			@status = data['status']

			raise InvalidDataError, 'No hash_type found' unless data.has_key?('hash_type')
			@hash_type = data['hash_type']

			raise InvalidDataError, 'No hash found' unless data.has_key?('hash')
			@hash = data['hash']

			raise InvalidDataError, 'No last_request found' unless data.has_key?('last_request')
			@last_request = DateTime.strptime(String(data['last_request']), '%s') unless data['last_request'].nil?

			raise InvalidDataError, 'No last_success found' unless data.has_key?('last_success')
			@last_success = DateTime.strptime(String(data['last_success']), '%s') unless data['last_success'].nil?

			raise InvalidDataError, 'No output_type found' unless data.has_key?('output_type')
			@output_type = data['output_type']

			raise InvalidDataError, 'No output_params found' unless data.has_key?('output_params')
			@output_params = parseOutputParams(data['output_params'])

			@is_deleted = true if @status == STATUS_DELETED
		end

		# Recursive method to parse the output_params as received from the API into
		# the flattened dot-notation used by the client libraries.
		# === Parameters
		#
		# * +params+ - A hash of parameters.
		# * +prefix+ - The current key prefix.
		#
		def parseOutputParams(params, prefix = '')
			retval = {}
			params.each do |k,v|
				if v.kind_of?(Hash)
					retval = retval.merge(parseOutputParams(v, prefix + k + '.'))
				else
					retval[prefix + k] = v
				end
			end
			return retval
		end

		# Reload the data for this subscription from the API.
		def reload()
			init(@user.callAPI('push/get', { 'id' => @id }))
		end

		# Name setter. Raises an InvalidDataError if this subscription has been
		# deleted.
		def name=(new_name)
			raise InvalidDataError, 'Cannot set the name of a deleted Push subscription' unless not @is_deleted
			@name = new_name
		end

		# Save changes to the name and output_params to the API.
		def save()
			raise InvalidDataError, 'Cannot save changes to a deleted Push subscription' unless not @is_deleted
			params = {
				'id'   => @id,
				'name' => @name
			}
			@output_params.each { |k,v| params[OUTPUT_PARAMS_PREFIX + k] = v }
			init(@user.callAPI('push/update', params))
		end

		# Pause this subscription.
		def pause()
			raise InvalidDataError, 'Cannot pause a deleted Push subscription' unless not @is_deleted
			init(@user.callAPI('push/pause', { 'id' => @id }))
		end

		# Resume this subscription.
		def resume()
			raise InvalidDataError, 'Cannot resume a deleted Push subscription' unless not @is_deleted
			init(@user.callAPI('push/resume', { 'id' => @id }))
		end

		# Resume this subscription.
		def stop()
			raise InvalidDataError, 'Cannot stop a deleted Push subscription' unless not @is_deleted
			init(@user.callAPI('push/stop', { 'id' => @id }))
		end

		# Delete this subscription.
		def delete()
			raise InvalidDataError, 'Cannot delete a deleted Push subscription' unless not @is_deleted
			@user.callAPI('push/delete', { 'id' => @id })
			# The delete API call does not return the object, so set the status
			# manually.
			@status = STATUS_DELETED
		end

		# Get a page of the log for this subscription, ordered as specified.
		# === Parameters
		#
		# * +page+ - The page number to get.
		# * +per_page+ - The number of items per page.
		# * +order_by+ - The field by which to order the results.
		# * +order_dir+ - Ascending or descending.
		#
		def getLog(page = 1, per_page = 20, order_by = ORDERBY_REQUEST_TIME, order_dir = ORDERDIR_DESC)
			return PushSubscription.getLogs(@user, page, per_page, order_by, order_dir, @id)
		end
	end
end
