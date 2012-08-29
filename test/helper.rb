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

		# Initialise the test data (parse the dates, etc).
		@testdata['historic_start'] = Date.parse(@testdata['historic_start'])
		@testdata['historic_end'] = Date.parse(@testdata['historic_end'])
		@testdata['historic_created_at'] = Date.parse(@testdata['historic_created_at'])
		@testdata['push_created_at'] = Date.parse(@testdata['push_created_at'])
		@testdata['push_last_request'] = Date.parse(@testdata['push_last_request'])
		@testdata['push_last_success'] = Date.parse(@testdata['push_last_success'])
		@testdata['historic_sources'] = @testdata['historic_sources'].split(',')

		@user = DataSift::User.new(@config['username'], @config['api_key'])
		@user.setApiClient(DataSift::MockApiClient.new())
		@user.api_client.clearResponse()
	end

	def set204Response()
		@user.api_client.setResponse(204, {}, 200, 150)
	end

	def setResponseToSingleHistoric(changes = {})
		data = {
				'id' => @testdata['historic_playback_id'],
				'definition_id' => @testdata['definition_hash'],
				'name' => @testdata['historic_name'],
				'start' => @testdata['historic_start'].strftime('%s'),
				'end' => @testdata['historic_end'].strftime('%s'),
				'created_at' => @testdata['historic_created_at'].strftime('%s'),
				'status' => @testdata['historic_status'],
				'progress' => 0,
				'sources' => @testdata['historic_sources'],
				'sample' => @testdata['historic_sample'],
				'volume_info' => {
					'digg' => 9
				},
			}
		@user.api_client.setResponse(200, data.merge(changes), 200, 150)
	end
end
