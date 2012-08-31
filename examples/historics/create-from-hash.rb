# This script creates a new Historics query from a stream hash.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Function to display usage instructions with an optional error message.
def usage(message = '', end_of_story = true)
	puts message + '\n' unless message.length() == 0
	puts
	puts 'Usage: create-from-hash \\'
	puts '            <username> <api_key> <hash> <start> <end> <sources> <name> <sample>'
	puts
	puts 'Where: hash    = the stream hash the query should run'
	puts '       start   = the start date for the query (YYYYMMDDHHMMSS)'
	puts '       end     = the end date for the query (YYYYMMDDHHMMSS)'
	puts '       sources = comma separated list of data sources (e.g. twitter)'
	puts '       name    = a friendly name for the query'
	puts '       sample  = the sample rate'
	puts
	puts 'Example'
	puts '       create-from-hash <hash> 20120101000000 20120101235959 \\'
	puts '                      twitter HistoricsQuery123 100'
	puts
	exit 1 unless not end_of_story
end

# Include the shared Env class
require File.dirname(__FILE__) + '/env'

# Create the env object. This reads the command line arguments, creates the
# user object, and provides access to both along with helper functions.
env = Env.new()

# Check that we have enough arguments
usage() unless env.args.size() == 6

# Read the arguments
stream_hash = env.args[0]
start_date  = env.args[1]
end_date    = env.args[2]
sources     = env.args[3].split(',')
name        = env.args[4]
sample      = env.args[5]

# Parse the dates
start_date = DateTime.strptime(start_date, '%Y%m%d%H%M%S')
end_date   = DateTime.strptime(end_date,   '%Y%m%d%H%M%S')

begin
	# Create the Historics query
	historic = env.user.createHistoric(stream_hash, start_date, end_date, sources, name, sample)

	# Prepare the query
	historic.prepare()

	# Display the details
	env.displayHistoricDetails(historic)

	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
 rescue DataSift::DataSiftError => err
	puts 'ERR: [' + err.class.name + '] ' + err.message
end
