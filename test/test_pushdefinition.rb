require 'helper'

class TestPushDefinition < Test::Unit::TestCase
	context "Given a new PushDefinition object" do
		setup do
			init()
			# Create the historic (API response is for compiling the definition)
			@push = @user.createPushDefinition()
		end

		should "be of the right type" do
			assert_not_nil @push
			assert @push.kind_of?(DataSift::PushDefinition)
		end

		should "have an empty initial status" do
			assert_equal '', @push.initial_status
		end

		should "allow the initial status to be changed" do
			@push.initial_status = DataSift::PushSubscription::STATUS_PAUSED
			assert_equal DataSift::PushSubscription::STATUS_PAUSED, @push.initial_status
			@push.initial_status = DataSift::PushSubscription::STATUS_STOPPED
			assert_equal DataSift::PushSubscription::STATUS_STOPPED, @push.initial_status
		end

		should "have an empty output type" do
			assert_equal '', @push.output_type
		end

		should "allow the output type to be set" do
			@push.output_type = @testdata['push_output_type']
			assert_equal @testdata['push_output_type'], @push.output_type
		end

		should "return nil for non-existant output parameters" do
			assert_nil @push.output_params['url']
		end

		should "allow output parameters to be set" do
			@push.output_params['url'] = @testdata['push_output_param_url']
			assert_equal @testdata['push_output_param_url'], @push.output_params['url']
			assert_equal 1, @push.output_params.size()
		end

		should "support validation of the output parameters" do
			configurePushDefinition(@push)
			set204Response()
			@push.validate()
		end

		should "support subscribing to a Definition object" do
			definition = @user.createDefinition(@testdata['definition'])
			# Set the response to the compile method so we can get the hash
			begin
				@user.api_client.setResponse(200, {
					'hash'       => @testdata['definition_hash'],
					'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
					'dpu'       => 10,
				}, 200, 150)
				assert_equal @testdata['definition_hash'], definition.hash
			rescue InvalidDataError
				assert false, "InvalidDataError"
			rescue CompileFailedError
				assert false, "CompileFailedError"
			rescue APIError
				assert false, "APIError"
			end

			configurePushDefinition(@push)

			setResponseToASingleSubscription()

			subscription = @push.subscribeDefinition(definition, @testdata['push_name'])

			checkSubscription(subscription)
		end

		should "support subscribing to a Historic object" do
			setResponseToASingleHistoric()
			historic = @user.getHistoric(@testdata['historic_playback_id'])

			configurePushDefinition(@push)

			setResponseToASingleSubscription()

			subscription = @push.subscribeHistoric(historic, @testdata['push_name'])

			checkSubscription(subscription)
		end
	end
end
