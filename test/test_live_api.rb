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

		should "have a positive DPU" do
			@definition.compile()
			assert @definition.total_dpu > 0
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

		should "fail to get the hash" do
			assert_raise(DataSift::CompileFailedError) { @definition.compile() }
			assert_raise(DataSift::CompileFailedError) { @definition.hash }
		end
	end

	context "The DPU returned from a valid Definition object" do
		setup do
			init()
			initUser(false)
			@definition = @user.createDefinition(@testdata['definition'])
			@dpu = @definition.getDPUBreakdown()
		end

		should "contain valid DPU data" do
			assert @dpu.has_key?('detail')
			assert @dpu.has_key?('dpu')
		end

		should "have a positive total DPU" do
			assert @dpu['dpu'] > 0
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
