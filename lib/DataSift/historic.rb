#
# historic.rb - This file contains the Historic class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The User class represents a user of the API. Applications should start their
# API interactions by creating an instance of this class. Once initialised it
# provides factory methods for all of the functionality in the API.

require 'date'

module DataSift

	# Definition class.
	#
	# == Introduction
	#
	# The Definition class represents a stream definition.
	#
	class Historic
		DEFAULT_SAMPLE = 100

		attr_reader :playback_id, :stream_hash, :name, :start_date, :end_date
		attr_reader :created_at, :status, :progress, :sources, :sample
		attr_reader :dpus, :volume_info, :is_deleted

		# Constructor. Pass all parameters to create a new Historics query, or provide a User object and a playback_id as the hash parameter to load an existing query from the API.
		# === Parameters
		#
		# * +user+ - The DataSift::User object.
		# * +hash+ - Either a stream_hash, an array containing the Historics query data or a playback ID.
		# * +start_date+ - The start date for a new Historics query.
		# * +end_date+ - The end date for a new Historics query.
		# * +sources+ - An array of sources for a new Historics query.
		# * +name+ - The name for a new Historics query.
		# * +sample+ - The sample rate for the new Historics query.
		#
		def initialize(user, hash, start_date = false, end_date = false, sources = false, name = false, sample = false)
			raise InvalidDataError, 'Please supply a valid User object when creating a Historic object.' unless user.is_a? DataSift::User
			@user = user

			if not start_date
				if hash.kind_of?(Array)
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
				start_date = Date.strftime(start_date, '%s') unless start_date.is_a? Date
				end_date = Date.strptime(end_date, '%s') unless end_date.is_a? Date
				raise InvalidDataError, 'Please supply an array of sources' unless sources.kind_of? Array

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

		# Reload the data for this object from the API.
		def reloadData()
			# Can't do this if we've been deleted
			raise InvalidDataError, 'Cannot reload the data for a deleted Historics query' unless not @is_deleted

			# Can't do this without a playback ID
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

		# Initialise this obejct from the data in an array.
		# === Parameters
		#
		# * +data+ - The array containing the data.
		#
		def initFromArray(data)
			raise APIError, 'No playback ID in the response' unless data.has_key?('id')
			raise APIError, 'Incorrect playback ID in the response' unless not @playback_id or data['id'] == @playback_id
			@playback_id = data['id']

			raise APIError, 'No definition hash in the response' unless data.has_key?('definition_id')
			@stream_hash = data['definition_id']

			raise APIError, 'No name in the response' unless data.has_key?('name')
			@name = data['name']

			raise APIError, 'No start timestamp in the response' unless data.has_key?('start')
			@start_date = Date.strptime(data['start'], '%s')

			raise APIError, 'No end timestamp in the response' unless data.has_key?('end')
			@end_date = Date.strptime(data['end'], '%s')

			raise APIError, 'No created at timstamp in the response' unless data.has_key?('created_at')
			@created_at = Date.strptime(data['created_at'], '%s')

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

			true
		end

		# Getter for the playback ID. If the Historics query has not yet been
		# prepared that will be done automagically to obtain the playback ID.
		def hash
			if @playback_id == false
				prepare()
			end

			@playback_id
		end

		# Name setter. Updates via the API if this Historics query has already
		# been prepared.
		def name=(new_name)
			raise InvalidDataError, 'Cannot set the name of a deleted Historics query' unless not @is_deleted

			if not @playback_id
				@name = new_name
			else
				@user.callAPI('historics/update', { 'id' => @playback_id, 'name' => new_name })
				reloadData()
			end
		end

		# Call the DataSift API to prepare this Historics query
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
		end

		# Start this Historics query.
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

		# Stop this Historics query.
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

		# Delete this Historics query.
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

		# Get a page of Push subscriptions for this Historics query, where each
		# page contains up to per_page items. Results will be returned in the
		# order requested.
		def getPushSubscriptions(page = 1, per_page = 20, order_by = 'created_at', order_dir = 'asc', include_finished = false)
			print 'Not yet implemented'
		end
	end

end
