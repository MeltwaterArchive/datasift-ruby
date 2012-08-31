# This script deletes Historics queries from your account.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the shared Env class
require File.dirname(__FILE__) + '/env'

# Create the env object. This reads the command line arguments, creates the
# user object, and provides access to both along with helper functions.
env = Env.new()

# Make sure we have something to do
abort('Please specify one or more playback IDs') unless env.args.size() > 0

begin
	for playback_id in env.args
		historic = env.user.getHistoric(playback_id)
		print 'Deleting ' + playback_id + ', "' + historic.name + '"...'
		historic.delete()
		puts 'done'
	end

	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
rescue DataSift::DataSiftError => err
	puts 'ERR: [' + err.class.name + '] ' + err.message
end
