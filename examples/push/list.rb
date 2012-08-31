# This script lists Push subscription in your account.
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

begin
	subscriptions = env.user.listPushSubscriptions()

	if subscriptions['subscriptions'].size() == 0
		puts 'No Push subscriptions exist in your account.'
	else
		for subscription in subscriptions['subscriptions']
			env.displaySubscriptionDetails(subscription)
		end
	end

	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
rescue DataSift::DataSiftError => err
	puts 'ERR: [' + err.class.name + '] ' + err.message
end
