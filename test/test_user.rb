require 'helper'

class TestUser < Test::Unit::TestCase
	context "Given a new User object" do
		setup do
			init()
			initUser()
		end

		should "have the correct username" do
			assert_not_nil @user
			assert_equal @config['username'], @user.username
		end

		should "have the correct API key" do
			assert_not_nil @user
			assert_equal @config['api_key'], @user.api_key
		end

		should "return valid summary usage information" do
			@user.api_client.setResponse(200, {
				'processed' => 9999,
				'delivered' => 10800,
				'streams' => [
					{
						'hash' => 'a123ab20f37f333824159b8868ad3827',
						'processed' => 7505,
						'delivered' => 8100
					},
					{
						'hash' => 'c369ab20f37f333824159b8868ad3827',
						'processed' => 2494,
						'delivered' => 2700
					}
				]
			}, 200, 150)
			usage = @user.getUsage()
			assert_equal 9999, usage['processed']
			assert_equal 10800, usage['delivered']
			assert_equal 'a123ab20f37f333824159b8868ad3827', usage['streams'][0]['hash']
		end
	end

	context "Given an empty definition from the User factory" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition()
		end

		should "have an empty CSDL" do
			assert_not_nil @definition
			assert_equal '', @definition.csdl
		end
	end

	context "Given an new definition from the User factory" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition("   " + @testdata['definition'])
		end

		should "have the correct CSDL" do
			assert_not_nil @definition
			assert_equal @testdata['definition'], @definition.csdl
		end
	end

	context "Given a call has been made to the API" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
			}, 200, 150)
			@definition.compile()
		end

		should "have a rate limit value" do
			assert @user.rate_limit == 200
		end

		should "have a rate limit remaining value" do
			assert @user.rate_limit_remaining == 150
		end
	end

	context "The exception raised by the User.getUsage method" do
		setup do
			init()
			initUser()
		end

		should "be APIError given a 400 response" do
			@user.api_client.setResponse(400, { 'error' => 'Bad request from user supplied data'}, 200, 150)
			assert_raise(DataSift::APIError) { usage = @user.getUsage() }
		end

		should "be AccessDenied given a 401 response" do
			@user.api_client.setResponse(401, { 'error' => 'User banned because they are a very bad person'}, 200, 150)
			assert_raise(DataSift::AccessDeniedError) { usage = @user.getUsage() }
		end

		should "be APIError given a 404 response" do
			@user.api_client.setResponse(404, { 'error' => 'Endpoint or data not found'}, 200, 150)
			assert_raise(DataSift::APIError) { usage = @user.getUsage() }
		end

		should "be APIError given a 500 response" do
			@user.api_client.setResponse(500, { 'error' => 'Problem with an internal service'}, 200, 150)
			assert_raise(DataSift::APIError) { usage = @user.getUsage() }
		end
	end
end
