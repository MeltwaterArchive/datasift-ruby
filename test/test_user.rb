require 'helper'

class TestUser < Test::Unit::TestCase
	context "Given a new User object" do
		setup do
			init()
			@user = DataSift::User.new(@config['username'], @config['api_key'])
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
			@user = DataSift::User.new(@config['username'], @config['api_key'])
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
			@user = DataSift::User.new(@config['username'], @config['api_key'])
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
			@user = DataSift::User.new(@config['username'], @config['api_key'])
			@definition = @user.createDefinition(@testdata['definition'])
			@definition.compile()
		end

		should "have a rate limit value" do
			assert @user.rate_limit != -1
		end

		should "have a rate limit remaining value" do
			assert @user.rate_limit_remaining != -1
		end
	end
end
