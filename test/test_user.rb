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
				'start' => 'Mon, 07 Nov 2011 14:20:00 +0000',
				'streams' => {
					'5e82aa9ac3dcf4dec1cce08a0cec914a' => {
						'seconds' => 313,
						'licenses' => {
							'twitter' => 17,
							'facebook' => 5
						}
					}
				},
				'end' => 'Mon, 07 Nov 2011 15:20:00 +0000'
			}, 200, 150)
			usage = @user.getUsage()
			assert_equal "Mon, 07 Nov 2011 14:20:00 +0000", usage['start']
			assert_equal "Mon, 07 Nov 2011 15:20:00 +0000", usage['end']
			assert_equal 313, usage['streams']['5e82aa9ac3dcf4dec1cce08a0cec914a']['seconds']
			assert_equal 17, usage['streams']['5e82aa9ac3dcf4dec1cce08a0cec914a']['licenses']['twitter']
			assert_equal 5, usage['streams']['5e82aa9ac3dcf4dec1cce08a0cec914a']['licenses']['facebook']
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
				'dpu'        => 10,
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
