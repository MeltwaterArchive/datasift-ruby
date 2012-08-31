require 'helper'

class TestPushSubscription < Test::Unit::TestCase
	context "Given a new PushSubsription object" do
		setup do
			init()
			# Get a subscription from the API
			setResponseToASingleSubscription()
			@subscription = @user.getPushSubscription(@testdata['push_id'])
		end

		should "be of the right type" do
			assert_not_nil @subscription
			assert @subscription.kind_of?(DataSift::PushSubscription)
		end
	end
end
