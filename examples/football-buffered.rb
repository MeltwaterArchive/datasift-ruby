# This example constructs a DataSift_Definition object with CSDL that looks
# for anything containing the word "football". It then sits in a loop,
# getting buffered interactions once every 10 seconds until it's retrieved
# 10.
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the DataSift library
require File.dirname(__FILE__) + '/../lib/datasift'

# Include the configuration - put your username and API key in this file
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Authenticate
puts 'Creating user...'
user = DataSift::User.new(config['username'], config['api_key'])

# Create the definition
csdl = 'interaction.content contains "football"'
puts 'Creating definition...'
puts '  ' + csdl
definition = user.createDefinition(csdl)

# Get buffered interactions until we've had 10
puts 'Getting buffered interactions...'
puts '--'
num = 10
from_id = false
begin
	interactions = definition.getBuffered(num, from_id)
	interactions.each do |interaction|
		puts 'Type: ' + interaction['interaction']['type']
		puts 'Content: ' + interaction['interaction']['content']
		puts '--'
		num -= 1
		from_id = interaction['interaction']['id']
	end

	if num > 0
		sleep(10)
	end
end while num > 0

puts
puts 'Fetched 10 interactions, we\'re done.'
puts
