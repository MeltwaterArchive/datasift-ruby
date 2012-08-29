# This class is used by the Historics examples to remove the noise of
# dealing with command line arguments.
#

# Include the DataSift library
require File.dirname(__FILE__) + '/../../lib/datasift'

class Env
	attr_reader :user, :args

	def initialize(args = false)
		if args === false
			args = ARGV
		end

		abort('Please specify your DataSift username and API key as the first two command line arguments!') unless args.size() >= 2

		username = args.shift
		api_key = args.shift
		@user = DataSift::User.new(username, api_key)

		@args = args
	end

	def displayHistoricDetails(historic)
		puts 'Playback ID: ' + historic.hash
		puts 'Stream hash: ' + historic.stream_hash
		puts 'Name:        ' + historic.name
		puts 'Start time:  ' + historic.start_date.strftime('%Y-%m-%d %H:%M:%S')
		puts 'End time:    ' + historic.end_date.strftime('%Y-%m-%d %H:%M:%S')
		puts 'Sources:     ' + historic.sources.join(', ')
		puts 'Sample:      ' + String(historic.sample)
		puts 'Created at:  ' + (historic.created_at.nil? ? 'None' : historic.created_at.strftime('%Y-%m-%d %H:%M:%S'))
		puts 'Status:      ' + historic.status
		puts '--'
	end
end
