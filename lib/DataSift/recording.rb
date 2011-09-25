#
# recording.rb - This file contains the Recording class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The Recording class represents a single recording.

module DataSift

	# Recording class.
	#
	# == Introduction
	#
	# The Recording class represents a single recording.
	#
	class Recording
		attr_reader :id, :start_time, :end_time, :name, :hash

		# Constructor. A User object is required, and either the data for this
		# recording, or a recording ID to fetch from the API.
		# === Parameters
		#
		# * +user+ - The DataSift::User object.
		# * +recording+ - An array containing the data for this recording, or a
		#                 recording ID to fetch it from the API.
		#
		def initialize(user, recording)
			raise InvalidDataError, 'Please supply a valid User object when creating a Recording object.' unless user.is_a? DataSift::User
			@user = user

			if !recording.kind_of?(Hash)
				# Got an ID, fetch the data
				recording = @user.callAPI('recording', { 'id' => recording })
			end

			init(recording)
		end

		# Initialise the object with the supplied data.
		# === Parameters
		#
		# * +recording+ - An array containing the ID, start_time, end_time,
		#                 name and hash.
		def init(recording)
			validateData(recording)

			@id = recording['id']
			@start_time = recording['start_time']
			if recording.has_key?('end_time')
				@end_time = recording['end_time']
			else
				@end_time = nil
			end
			@name = recording['name']
			@hash = recording['hash']
			@deleted = false
		end

		# Validate a set of data. Pass false as the second parameter to disable
		# checking to make sure all parts of a recording are present.
		# === Parameters
		#
		# * +data+ - The data to validate.
		# * +check_for_missing_values+ - Set to false to ignore missing data.
		def validateData(data, check_for_missing_values = true)
			if check_for_missing_values
				raise InvalidDataError, 'Missing ID in the recording data' unless data.has_key?('id')
				raise InvalidDataError, 'Missing start_time in the recording data' unless data.has_key?('start_time')
				raise InvalidDataError, 'Missing name in the recording data' unless data.has_key?('name')
				raise InvalidDataError, 'Missing hash in the recording data' unless data.has_key?('hash')
			end

			if data.has_key?('id')
				raise InvalidDataError, 'Invalid ID in the recording data' unless data['id'].is_a?(String)
			end

			if data.has_key?('start_time')
				raise InvalidDataError, 'Invalid start_time in the recording data' unless data['start_time'].is_a?(Integer) or data['start_time'] < 0
			end

			if data.has_key?('name')
				raise InvalidDataError, 'Invalid name in the recording data' unless (data['name'].is_a?(String) and data['name'].strip != '')
			end

			if data.has_key?('hash')
				raise InvalidDataError, 'Invalid hash in the recording data' unless (data['hash'].is_a?(String) and data['hash'].strip != '')
			end
		end

		# Throw an exception if this recording has been deleted.
		def checkDeleted()
			raise InvalidDataError, 'This recording has been deleted!' unless !@deleted
		end

		# Return the ID
		def id
			checkDeleted()
			@id
		end

		# Return the start_time
		def start_time
			checkDeleted()
			@start_time
		end

		# Return the end_time
		def end_time
			checkDeleted()
			@end_time
		end

		# Return the start_time
		def name
			checkDeleted()
			@name
		end

		# Return the hash
		def hash
			checkDeleted()
			@hash
		end

		# Update the recording data
		# === Parameters
		#
		# * +data+ - A hash containing the data to update (name, start_time and/or end_time)
		def update(data)
			checkDeleted()

			# Make sure we have the right sort of variable
			if !data.kind_of?(Hash)
				raise InvalidDataError, 'The data passed in for an update must be a hash'
			end

			# Validate the data
			validateData(data, false)

			# Build the API call parameters
			params = {}

			if data.has_key?('name')
				params['name'] = data['name']
				data.delete('name')
			end

			if data.has_key?('start_time')
				params['start'] = data['start_time']
				data.delete('start_time')
			end

			if data.has_key?('end_time')
				params['end'] = data['end_time']
				data.delete('end_time')
			end

			# If there's anything left in the data hash, raise an exception
			if data.keys.count > 0
				raise InvalidDataError, 'Unexpected data for update: ' + data.keys.join(', ')
			end

			# Add the ID to the parameters
			params['id'] = @id

			# Make the call
			recording = @user.callAPI('recording/update', $params)

			# Update this object with the results
			init(recording)
		end

		# Delete this recording
		def delete()
			checkDeleted()

			res = @user.callAPI('recording/delete', { id => @id })

			if !res.has_key?('success') or res['success'] != 'true'
				raise APIError, 'Delete operation failed'
			end

			@deleted = true
		end

		# Start a new export of the data contained within this recording.
		# === Parameters
		#
		# * +format+ - The format for the export. Use one of the RecordingExport::FORMAT_* constants.
		# * +name+ - An optional name for the export.
		# * +start_time+ - An optional start timestamp.
		# * +end_time+ - An optional end timestamp.
		def startExport(format = RecordingExport::FORMAT_JSON, name = false, start_time = false, end_time = false)
			checkDeleted()

			params = { recording_id => @id }

			# Check the format
			if ![RecordingExport::FORMAT_JSON, RecordingExport::FORMAT_XLS, RecordingExport::FORMAT_XLSX].include?(format)
				raise InvalidDataError, 'Invalid export format specified'
			end

			# Check the name is valid if provided
			if name != false
				if !name.is_a(String) or name == ''
					raise InvalidDataError, 'The export name must be a non-empty string'
				end
				params['name'] = name
			end

			# Check the start parameter
			if start_time != false
				if !start_time.is_a?(Integer) or start_time < 0
					raise InvalidDataError, 'The start timestamp must be a positive integer'
				end

				if start_time < @start_time
					raise InvalidDataError, 'The start timestamp must be equal to or greater than the recording start timestamp'
				end

				if start_time >= @end_time
					raise InvalidDataError, 'The start timestamp must be less than the recording end timestamp'
				end

				params['start'] = start_time
			end

			# Check the end parameter
			if end_time != false
				if !end_time.is_a?(Integer) or end_time < 0
					raise InvalidDataError, 'The end timestamp must be a positive integer'
				end

				if end_time > @end_time
					raise InvalidDataError, 'The end timestamp must be less than or equal to the recording end timestamp'
				end

				if start_time != false and end_time < start_time
					raise InvalidDataError, 'The end timestamp must be greater than the start timestamp'
				end

				params['end'] = end_time
			end

			res = @user.callAPI('recording/export/start', params)

			RecordingExport.new(@user, res)
		end
	end
end
