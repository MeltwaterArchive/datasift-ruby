# This example consumes 1% of tweets, displaying a . for each interaction
# received, and an X for each delete notification.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the DataSift library
require File.dirname(__FILE__) + '/../lib/datasift'

# Include the configuration - put your username and API key in this file
require 'yaml'
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Authenticate
puts 'Creating user...'
user = DataSift::User.new(config['username'], config['api_key'])

# Create the definition
csdl = 'interaction.type == "twitter" AND interaction.sample < 1.0'
puts 'Creating definition...'
puts '  ' + csdl
definition = user.createDefinition(csdl)

# Create the consumer
puts 'Getting the consumer...'
consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)

# Set up the delete event handler. Refer to the documentation for details of
# what the interaction variable will contain:
# http://dev.datasift.com/docs/twitter-deletes
consumer.onDeleted do |interaction|
	print 'X'
	$stdout.flush
end

# And start consuming
puts 'Consuming...'
puts '--'
consumer.consume(true) do |interaction|
	if interaction
		print '.'
		$stdout.flush
	end
end

# This example will not stop unless it gets disconnected
puts
puts 'Consumer stopped'
puts
