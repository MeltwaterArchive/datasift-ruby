require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'yaml'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'datasift'

class Test::Unit::TestCase
	def init()
		@config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))
		@testdata = YAML::load(File.open(File.join(File.dirname(__FILE__), 'testdata.yml')))
	end
end
