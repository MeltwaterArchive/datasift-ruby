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
end
