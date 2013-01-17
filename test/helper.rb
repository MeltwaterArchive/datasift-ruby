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
		@testdata['historic_start'] = DateTime.parse(@testdata['historic_start'])
		@testdata['historic_end'] = DateTime.parse(@testdata['historic_end'])
		@testdata['historic_created_at'] = DateTime.parse(@testdata['historic_created_at'])
		@testdata['push_created_at'] = DateTime.parse(@testdata['push_created_at'])
		@testdata['push_last_request'] = DateTime.parse(@testdata['push_last_request'])
		@testdata['push_last_success'] = DateTime.parse(@testdata['push_last_success'])
		@testdata['historic_sources'] = @testdata['historic_sources'].split(',')

		@user = DataSift::User.new(@config['username'], @config['api_key'])
		@user.setApiClient(DataSift::MockApiClient.new())
		@user.api_client.clearResponse()
	end

	def set204Response()
		@user.api_client.setResponse(204, {}, 200, 150)
	end

	def setResponseToASingleHistoric(changes = {})
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
			}
		@user.api_client.setResponse(200, data.merge(changes), 200, 150)
	end

	def configurePushDefinition(push)
		push.output_type = @testdata['push_output_type']
		@testdata['push_output_params'].each { |k,v| push.output_params[k] = v }
	end

	def setResponseToASingleSubscription(changes = {})
		data = {
				'id'            => @testdata['push_id'],
				'name'          => @testdata['push_name'],
				'created_at'    => @testdata['push_created_at'].strftime('%s'),
				'status'        => @testdata['push_status'],
				'hash'          => @testdata['definition_hash'],
				'hash_type'     => @testdata['push_hash_type'],
				'output_type'   => @testdata['push_output_type'],
				'output_params' => {
					'delivery_frequency' => @testdata['push_output_params']['delivery_frequency'],
					'url'                => @testdata['push_output_params']['url'],
					'auth'               => {
						'type'      => @testdata['push_output_params']['auth_type'],
						'username'	=> @testdata['push_output_params']['auth_username'],
						'password'	=> @testdata['push_output_params']['auth_password'],
					},
				},
				'last_request'  => @testdata['push_last_request'].strftime('%s'),
				'last_success'  => @testdata['push_last_success'].strftime('%s'),
			}
		@user.api_client.setResponse(200, data.merge(changes), 200, 150)
	end

	def checkSubscription(subscription)
		assert_equal @testdata['push_id'],                                  subscription.id
		assert_equal @testdata['push_name'],                                subscription.name
		assert_equal @testdata['push_created_at'],                          subscription.created_at
		assert_equal @testdata['push_status'],                              subscription.status
		assert_equal @testdata['definition_hash'],                          subscription.hash
		assert_equal @testdata['push_hash_type'],                           subscription.hash_type
		assert_equal @testdata['push_output_type'],                         subscription.output_type
		assert_equal @testdata['push_output_params']['delivery_frequency'], subscription.output_params['delivery_frequency']
		assert_equal @testdata['push_output_params']['url'],                subscription.output_params['url']
		assert_equal @testdata['push_output_params']['auth_type'],          subscription.output_params['auth.type']
		assert_equal @testdata['push_output_params']['auth_username'],      subscription.output_params['auth.username']
		assert_equal @testdata['push_output_params']['auth_password'],      subscription.output_params['auth.password']
		assert_equal @testdata['push_last_request'],                        subscription.last_request
		assert_equal @testdata['push_last_success'],                        subscription.last_success
	end
end
