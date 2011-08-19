require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'yaml'
require File.dirname(__FILE__) + '/../lib/DataSift/mockapiclient'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'datasift'

class Test::Unit::TestCase
	def init()
		@config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))
		@testdata = YAML::load(File.open(File.join(File.dirname(__FILE__), 'testdata.yml')))
	end

	def initUser(mock = true)
			@user = DataSift::User.new(@config['username'], @config['api_key'])
			if mock
				@user.setApiClient(DataSift::MockApiClient.new())
				@user.api_client.clearResponse()
			end
	end
end
