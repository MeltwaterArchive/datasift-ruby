# This example gets the DPU associated with the stream given on the command
# line or piped/typed into STDIN. It  presents it in a nice ASCII table.]
# Note that the CSDL must be enclosed in quotes if given on the command line.
#
# ruby dpu.rb 'interaction.content contains "football"'
#  or
# cat football.csdl | ruby dpu.rb
#
# NB: Most of the error handling (exception catching) has been removed for
# the sake of simplicity. Nearly everything in this library may throw
# exceptions, and production code should catch them. See the documentation
# for full details.
#

# Include the DataSift library
require './' + File.dirname(__FILE__) + '/../lib/datasift'

# Function to format a number with commas
def number_with_delimiter(number, delimiter=',')
  number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
end

# Include the configuration - put your username and API key in this file
require 'yaml'
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

# Get the CSDL from the command line or STDIN
# Make sure we have some arguments
if ARGV.size == 0
	puts 'ERR: Please specify the hash to consume!'
	puts
	exit!
elsif ARGV.size > 0
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

# Getting DPU
puts 'Getting DPU...'
begin
	dpu = definition.getDPUBreakdown()
rescue DataSift::CompileFailedError => e
	puts 'CSDL compilation failed: ' + e.message
	puts
	exit!
end

dputable = []
maxlength = {'target' => 'Target'.length, 'times used' => 'Times used'.length, 'complexity' => 'Complexity'.length};
dpu['detail'].each do |tgt,c|
	maxlength['target'] = [maxlength['target'], tgt.length].max()
	maxlength['times used'] = [maxlength['times used'], number_with_delimiter(c['count']).length].max()
	maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(c['dpu']).length].max()

	dputable.push({
			'target' => tgt,
			'times used' => number_with_delimiter(c['count']),
			'complexity' => number_with_delimiter(c['dpu']),
		})

	c['targets'].each do |tgt2,d|
		maxlength['target'] = [maxlength['target'], 2 + tgt2.length].max()
		maxlength['times used'] = [maxlength['times used'], number_with_delimiter(d['count']).length].max()
		maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(d['dpu']).length].max()

		dputable.push({
				'target' => '  ' + tgt2,
				'times used' => number_with_delimiter(d['count']),
				'complexity' => number_with_delimiter(d['dpu']),
			})
	end
end

maxlength['complexity'] = [maxlength['complexity'], number_with_delimiter(dpu['dpu']).length].max()

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

dputable.each do |row|
	print '| ' + row['target'].ljust(maxlength['target']) + ' | '
	print row['times used'].rjust(maxlength['times used']) + ' | '
	puts row['complexity'].rjust(maxlength['complexity']) + ' |'
end

print '|-' + ('-' * maxlength['target']) + '-+-'
print ('-' * maxlength['times used']) + '-+-'
puts ('-' * maxlength['complexity']) + '-|'

print '| ' + 'Total'.rjust(maxlength['target'] + 3 + maxlength['times used']) + ' = '
puts dpu['dpu'].to_s.rjust(maxlength['complexity']) + ' |'

print '\\-' + ('-' * maxlength['target']) + '---'
print ('-' * maxlength['times used']) + '---'
puts ('-' * maxlength['complexity']) + '-/'

puts
