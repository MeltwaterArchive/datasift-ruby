# This script creates a Push subscription for a stream hash or Historics
# playback ID.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the shared Env class
require File.dirname(__FILE__) + '/env'

# Display usage information, with an error message if provided.
def usage(message = '', end_of_story = true)
	puts message + '\n' unless message.length() == 0
	puts
	puts 'Usage: push-from-hash.rb <username> <api_key> \\'
	puts '                 <output_type> <hash_type> <hash> <name> ...'
	puts
	puts 'Where: output_type = http (currently only http is supported)'
	puts '       hash_type   = stream | historic'
	puts '       hash        = the hash'
	puts '       name        = a friendly name for the subscription'
	puts '       key=val     = output_type-specific arguments'
	puts
	puts 'Example'
	puts '       push-from-hash.rb http stream <hash> PushName delivery_frequency=10 \\'
	puts '             url=http://www.example.com/push_endpoint auth.type=none'
	puts
	exit 1 unless not end_of_story
end

# Create the env object. This reads the command line arguments, creates the
# user object, and provides access to both along with helper functions.
env = Env.new()

# Check that we have enough arguments
usage() if env.args.size() < 4

# Read the arguments
output_type = env.args.shift
hash_type   = env.args.shift
hash        = env.args.shift
name        = env.args.shift

begin
	# Create the Push definition
	pushdef = env.user.createPushDefinition()
	pushdef.output_type = output_type

	# Now add the output_type-specific args from the command line
	while env.args.size() > 0
		k, v = env.args.shift.split('=', 2)
		pushdef.output_params[k] = v
	end

	# Subscribe the hash to the Push endpoint
	if hash_type == 'stream'
		sub = pushdef.subscribeStreamHash(hash, name)
	elsif hash_type == 'historic'
		sub = pushdef.subscribeHistoricPlaybackId(hash, name)
	else
		usage('Invalid hash_type: ' + hash_type)
	end

	# Display the details of the new subscription
	env.displaySubscriptionDetails(sub)

	puts 'Rate limit remainining: ' + String(env.user.rate_limit_remaining)
rescue DataSift::DataSiftError => err
	puts 'ERR: [' + err.class.name + '] ' + err.message
end
