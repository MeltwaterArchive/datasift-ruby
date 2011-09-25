require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'yaml'
require 'crack'
require File.dirname(__FILE__) + '/../lib/DataSift/mockapiclient'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'datasift'

class Test::Unit::TestCase
	def init()
		@config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))
		tmp = YAML::load(File.open(File.join(File.dirname(__FILE__), 'testdata.yml')))
		@testdata = {}
		tmp.each_pair do |k,v|
			if k.end_with?('_json')
				@testdata[k[0..-6]] = Crack::JSON.parse(v)
			else
				@testdata[k] = v
			end
		end
	end

	def initUser(mock = true)
			@user = DataSift::User.new(@config['username'], @config['api_key'])
			if mock
				@user.setApiClient(DataSift::MockApiClient.new())
				@user.api_client.clearResponse()
			end
	end
end
