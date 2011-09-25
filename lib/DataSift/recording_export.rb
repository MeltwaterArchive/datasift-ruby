#
# recording_export.rb - This file contains the RecordingExoport class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The RecordingExport class represents a single recording export.

module DataSift

	# RecordingExport class.
	#
	# == Introduction
	#
	# The RecordingExport class represents a single recording export.
	#
	class RecordingExport
		# Format constants
		FORMAT_JSON = 'json'
		FORMAT_XLS = 'xls'
		FORMAT_XLSX = 'xlsx'

		# Status constants
		STATUS_SETUP = 'setup'
		STATUS_PREP = 'prep'
		STATUS_RUNNING = 'running'
		STATUS_SUSPENDED = 'suspended'
		STATUS_SUCCEEDED = 'succeeded'
		STATUS_FAILED = 'failed'
		STATUS_KILLED = 'killed'

		attr_reader :id, :recording_id, :start_time, :end_time, :name, :status

		# Constructor. A User object is required, and either the data for this
		# recording, or a recording ID to fetch from the API.
		# === Parameters
		#
		# * +user+ - The DataSift::User object.
		# * +export+ - An array containing the data for this recording, or a
		#              recording ID to fetch it from the API.
		#
		def initialize(user, export)
			raise InvalidDataError, 'Please supply a valid User object when creating a RecordingExport object.' unless user.is_a? DataSift::User
			@user = user

			if !export.kind_of?(Hash)
				# Got an ID, fetch the data
				export = @user.callAPI('recording/export', { 'id' => export })
			end

			init(export)
		end

		# Initialise the object with the supplied data.
		# === Parameters
		#
		# * +export+ - An array containing the ID, recording ID, name, start, end
		#              and status.
		def init(export)
			validateData(export)

			@id = export['id']
			@recording_id = export['recording_id']
			@name = export['name']
			@start_time = export['start']
			@end_time = export['end']
			@status = export['status']
			@deleted = false
		end

		# Validate a set of data. Pass false as the second parameter to disable
		# checking to make sure all parts of an export are present.
		# === Parameters
		#
		# * +data+ - The data to validate.
		# * +check_for_missing_values+ - Set to false to ignore missing data.
		def validateData(data, check_for_missing_values = true)
			if check_for_missing_values
				raise InvalidDataError, 'Missing ID in the export data' unless data.has_key?('id')
				raise InvalidDataError, 'Missing recording_id in the export data' unless data.has_key?('recording_id')
				raise InvalidDataError, 'Missing name in the export data' unless data.has_key?('name')
				raise InvalidDataError, 'Missing start_time in the export data' unless data.has_key?('start')
				raise InvalidDataError, 'Missing end_time in the export data' unless data.has_key?('end')
				raise InvalidDataError, 'Missing status in the export data' unless data.has_key?('status')
			end

			if data.has_key?('id')
				raise InvalidDataError, 'Invalid ID in the export data' unless (data['id'].is_a?(String) and data['id'].strip != '')
			end

			if data.has_key?('recording_id')
				raise InvalidDataError, 'Invalid recording_id in the export data' unless (data['recording_id'].is_a?(String) and data['id'].strip != '')
			end

			if data.has_key?('start')
				raise InvalidDataError, 'Invalid start in the export data' unless data['start'].is_a?(Integer) or data['start'] < 0
			end

			if data.has_key?('name')
				raise InvalidDataError, 'Invalid name in the export data' unless (data['name'].is_a?(String) and data['name'].strip != '')
			end

			if data.has_key?('hash')
				raise InvalidDataError, 'Invalid status in the export data' unless (data['status'].is_a?(String) and data['status'].strip != '')
			end
		end

		# Throw an exception if this recording has been deleted.
		def checkDeleted()
			raise InvalidDataError, 'This export has been deleted!' unless !@deleted
		end

		# Return the ID
		def id
			checkDeleted()
			@id
		end

		# Return the recording ID
		def recording_id
			checkDeleted()
			@recording_id
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

		# Return the status
		def status
			checkDeleted()
			@status
		end

		# Delete this recording
		def delete()
			checkDeleted()

			res = @user.callAPI('recording/export/delete', { id => @id })

			if !res.has_key?('success') or res['success'] != 'true'
				raise APIError, 'Delete operation failed'
			end

			@deleted = true
		end
	end
end
