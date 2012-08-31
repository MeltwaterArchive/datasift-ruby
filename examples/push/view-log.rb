# This script resumes Push subscriptions in your account.
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

# Make sure we have 0 or 1 arguments
abort('Please specify one or more subscription IDs') unless env.args.size() < 2

begin
	# Get the log
	arg_count = env.args.size()
	if arg_count == 0
		log = env.user.getPushSubscriptionLog()
	else
		subscription_id = env.args[0]
		log = env.user.getPushSubscriptionLog(subscription_id)
	end

	# Make sure we have some log entries
	abort('No log entries found.') unless log['count'] > 0

	# Display the log entries in reverse order
	log['log_entries'].reverse().each do |log_entry|
		print (DateTime.strptime(String(log_entry['request_time']), '%s')).strftime('%Y-%m-%d %H:%M:%S') + ' '
		print '[' + log_entry['subscription_id'] + '] ' if arg_count == 0
		print 'Success ' if log_entry['success']
		puts log_entry['message']
	end
rescue DataSift::DataSiftError => err
	puts 'ERR: [' + err.class.name + '] ' + err.message
end

if env.user.rate_limit_remaining != -1
	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
end
