require 'helper'

class TestDefinitionLive < Test::Unit::TestCase
	context "Given a Definition object with a valid CSDL" do
		setup do
			init()
			initUser(false)
			@user = DataSift::User.new(@config['username'], @config['api_key'])
			@definition = @user.createDefinition(@testdata['definition'])
		end

		should "compile the definition successfully" do
			begin
				@definition.compile()
			rescue InvalidDataError
				assert false, "InvalidDataError"
			rescue CompileFailedError
				assert false, "CompileFailedError"
			rescue APIError
				assert false, "APIError"
			end
		end

		should "have the correct hash" do
			@definition.compile()
			assert_equal @testdata['definition_hash'], @definition.hash
		end

		should "have a positive cost" do
			@definition.compile()
			assert @definition.total_cost > 0
		end

		should "have a valid created_at date" do
			@definition.compile()
			assert @definition.created_at
		end
	end

	context "Given a Definition object with an invalid CSDL" do
		setup do
			init()
			initUser(false)
			@definition = @user.createDefinition(@testdata['invalid_definition'])
		end

		should "fail to compile the definition" do
			assert_raise(DataSift::CompileFailedError) { @definition.compile() }
		end

		should "have a hash of false" do
			assert_raise(DataSift::CompileFailedError) { @definition.compile() }
			assert_equal false, @definition.hash
		end
	end

	context "The cost returned from a valid Definition object" do
		setup do
			init()
			initUser(false)
			@definition = @user.createDefinition(@testdata['definition'])
			@cost = @definition.getCostBreakdown()
		end

		should "contain valid cost data" do
			assert @cost.has_key?('costs')
			assert @cost.has_key?('total')
		end

		should "have a positive total cost" do
			assert @cost['total'] > 0
		end
	end

	context "Buffered data returned by a valid Definition object" do
		setup do
			init()
			initUser(false)
			@definition = @user.createDefinition(@testdata['definition'])
			@interactions = @definition.getBuffered()
		end

		should "be valid" do
			assert @interactions
		end
	end

	context "A StreamConsumer object returned by a valid Definition object" do
		setup do
			init()
			initUser(false)
			@definition = @user.createDefinition(@testdata['definition'])
			@consumer = @definition.getConsumer()
		end

		should "be valid" do
			assert @consumer.is_a? DataSift::StreamConsumer
		end
	end
end
