# This script views the details of Push subscriptions in your account.
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
abort('Please specify one or more subscription IDs') unless env.args.size() > 0

for sub_id in env.args
	begin
		sub = env.user.getPushSubscription(sub_id)
		env.displaySubscriptionDetails(sub)
	rescue DataSift::DataSiftError => err
		puts 'ERR: [' + err.class.name + '] ' + err.message
		puts '--'
	end
end

if env.user.rate_limit_remaining != -1
	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
end
