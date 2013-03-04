# This example constructs a DataSift_Definition object with CSDL that looks
# for anything containing the word "football". It then gets an HTTP
# consumer for that definition and displays matching interactions to the
# screen as they come in. It will display 10 interactions and then stop.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the DataSift library
require './' + File.dirname(__FILE__) + '/../lib/datasift'

# Include the configuration - put your username and API key in this file
require 'yaml'
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Authenticate
puts 'Creating user...'
user = DataSift::User.new(config['username'], config['api_key'])

# Create the definition
csdl = 'interaction.content contains "football"'
puts 'Creating definition...'
puts '  ' + csdl
definition = user.createDefinition(csdl)

# Create the consumer
puts 'Getting the consumer...'
consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)

# And start consuming
puts 'Consuming...'
puts '--'
count = 10
consumer.consume(true) do |interaction|
	if interaction
		puts 'Type: ' + interaction['interaction']['type']
		puts 'Content: ' + interaction['interaction']['content']
		puts '--'

		count -= 1
		if count == 0
			puts 'Stopping consumer...'
			consumer.stop()
		end
	end
end

puts
puts 'Finished consuming'
puts
