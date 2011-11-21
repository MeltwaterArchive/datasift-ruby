# This simple example demonstrates consuming a stream from just the stream
# hash.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Make sure we have some arguments
if ARGV.size == 0
	puts 'ERR: Please specify the hash to consume!'
	puts
	puts
	exit!
end

# Include the DataSift library
require File.dirname(__FILE__) + '/../lib/datasift'

# Include the configuration - put your username and API key in this file
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Authenticate
puts 'Creating user...'
user = DataSift::User.new(config['username'], config['api_key'])

# Create the consumer
puts 'Getting the consumer...'
consumer = user.getConsumer(DataSift::StreamConsumer::TYPE_HTTP, ARGV[0])

# Setting up the onStopped handler
consumer.onStopped do |reason|
	puts
	puts 'Stopped: ' + reason
	puts
end

# And start consuming
puts 'Consuming...'
puts '--'
consumer.consume(true) do |interaction|
	if interaction
		puts 'Type: ' + interaction['interaction']['type']
		puts 'Content: ' + interaction['interaction']['content']
		puts '--'
	end
end

puts
puts 'Finished consuming'
puts
