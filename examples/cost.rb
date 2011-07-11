# This example gets the cost associated with the stream given on the command
# line or piped/typed into STDIN. It  presents it in a nice ASCII table.]
# Note that the CSDL must be enclosed in quotes if given on the command line.
#
# ruby cost.rb 'interaction.content contains "football"'
#  or
# cat football.csdl | ruby cost.rb
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the DataSift library
require File.dirname(__FILE__) + '/../lib/datasift'

# Function to format a number with commas
def number_with_delimiter(number, delimiter=',')
  number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
end

# Include the configuration - put your username and API key in this file
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Get the CSDL from the command line or STDIN
if ARGV.size > 0
	csdl = ARGV[0]
else
	csdl = ARGF.read
end

# Authenticate
puts 'Creating user...'
user = DataSift::User.new(config['username'], config['api_key'])

# Create the definition
puts 'Creating definition...'
definition = user.createDefinition(csdl)

# Getting cost
puts 'Getting cost...'
begin
	cost = definition.getCostBreakdown()
rescue DataSift::CompileFailedError => e
	puts 'CSDL compilation failed: ' + e
	puts
	exit!
end

costtable = []
maxlength = {'target' => 'Target'.length, 'times used' => 'Times used'.length, 'complexity' => 'Complexity'.length};
cost['costs'].each do |tgt,c|
	maxlength['target'] = [maxlength['target'], tgt.length].max()
	maxlength['times used'] = [maxlength['times used'], number_with_delimiter(c['count']).length].max()
	maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(c['cost']).length].max()

	costtable.push({
			'target' => tgt,
			'times used' => number_with_delimiter(c['count']),
			'complexity' => number_with_delimiter(c['cost']),
		})

	c['targets'].each do |tgt2,d|
		maxlength['target'] = [maxlength['target'], 2 + tgt2.length].max()
		maxlength['times used'] = [maxlength['times used'], number_with_delimiter(d['count']).length].max()
		maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(d['cost']).length].max()

		costtable.push({
				'target' => '  ' + tgt2,
				'times used' => number_with_delimiter(d['count']),
				'complexity' => number_with_delimiter(d['cost']),
			})
	end
end

maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(cost['total']).length].max()

puts
print '/-' + ('-' * maxlength['target']) + '---'
print ('-' * maxlength['times used']) + '---'
puts ('-' * maxlength['complexity']) + '-\\'

print '| ' + 'Target'.ljust(maxlength['target']) + ' | '
print 'Times Used'.ljust(maxlength['times used']) + ' | '
puts 'Complexity'.ljust(maxlength['complexity']) + ' |'

print '|-' + ('-' * maxlength['target']) + '-+-'
print ('-' * maxlength['times used']) + '-+-'
puts ('-' * maxlength['complexity']) + '-|'

costtable.each do |row|
	print '| ' + row['target'].ljust(maxlength['target']) + ' | '
	print row['times used'].rjust(maxlength['times used']) + ' | '
	puts row['complexity'].rjust(maxlength['complexity']) + ' |'
end

print '|-' + ('-' * maxlength['target']) + '-+-'
print ('-' * maxlength['times used']) + '-+-'
puts ('-' * maxlength['complexity']) + '-|'

print '| ' + 'Total'.rjust(maxlength['target'] + 3 + maxlength['times used']) + ' = '
puts cost['total'].to_s.rjust(maxlength['complexity']) + ' |'

print '\\-' + ('-' * maxlength['target']) + '---'
print ('-' * maxlength['times used']) + '---'
puts ('-' * maxlength['complexity']) + '-/'

puts

if cost['total'] > 1000
	tiernum = 3;
	tierdesc = 'high complexity';
elsif cost['total'] > 100
	tiernum = 2;
	tierdesc = 'medium complexity';
else
	tiernum = 1;
	tierdesc = 'simple complexity';
end

puts 'A total cost of ' + number_with_delimiter(cost['total']) + ' puts this stream in tier ' + tiernum.to_s + ', ' + tierdesc
puts
