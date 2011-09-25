require 'helper'

class TestRecording < Test::Unit::TestCase
	context "A valid Recording object created from an array" do
		setup do
			init()
			initUser()
			@recording = DataSift::Recording.new(@user, @testdata['recording'])
		end

		should "contain the correct data" do
			assert_equal @testdata['recording']['id'], @recording.id
			assert_equal @testdata['recording']['start_time'], @recording.start_time
			assert_equal @testdata['recording']['finish_time'], @recording.end_time
			assert_equal @testdata['recording']['name'], @recording.name
			assert_equal @testdata['recording']['hash'], @recording.hash
		end
	end

	context "A valid Recording object created from an ID" do
		setup do
			init()
			initUser()
			@user.api_client.setResponse(200, @testdata['recording'], 200, 150)
			@recording = DataSift::Recording.new(@user, @testdata['recording']['id'])
		end

		should "contain the correct data" do
			assert_equal @testdata['recording']['id'], @recording.id
			assert_equal @testdata['recording']['start_time'], @recording.start_time
			assert_equal @testdata['recording']['finish_time'], @recording.end_time
			assert_equal @testdata['recording']['name'], @recording.name
			assert_equal @testdata['recording']['hash'], @recording.hash
		end
	end

	context "A valid Recording object" do
		setup do
			init()
			initUser()
			@user.api_client.setResponse(200, @testdata['recording'], 200, 150)
			@recording = DataSift::Recording.new(@user, @testdata['recording']['id'])
		end

		should "allow the name to be updated" do
			expected = @testdata['recording']
			expected['name'] = 'New recording name'
			@user.api_client.setResponse(200, expected, 200, 150)
			@recording.update({ 'name' => expected['name'] })
			assert_equal expected['name'], @recording.name
		end

		should "allow the start and end times to be updated" do
			expected = @testdata['recording']
			expected['start_time'] += 86400
			expected['end_time'] = expected['start_time'] + 86400
			@user.api_client.setResponse(200, expected, 200, 150)
			@recording.update({ 'start_time' => expected['start_time'], 'end_time' => expected['end_time'] })
			assert_equal expected['start_time'], @recording.start_time
			assert_equal expected['end_time'], @recording.end_time
		end

		should "throw an exception if update is called with an invalid parameter" do
			assert_raise(DataSift::InvalidDataError) { @recording.update(false) }
		end

		should "throw an exception if update is called with invalid keys in the data hash" do
			assert_raise(DataSift::InvalidDataError) { @recording.update({ 'oops' => 'wrong' }) }
		end

		should "throw an exception if update is called with an invalid value in the data hash" do
			assert_raise(DataSift::InvalidDataError) { @recording.update({ 'name' => false }) }
		end
	end

	context "The exception raised by the Recording.update method" do
		setup do
			init()
			initUser()
			@recording = DataSift::Recording.new(@user, @testdata['recording'])
		end

		should "be APIError given a 400 response" do
			@user.api_client.setResponse(400, { 'error' => 'Bad request from user supplied data'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.update({ 'name' => 'New recording name' }) }
		end

		should "be AccessDenied given a 401 response" do
			@user.api_client.setResponse(401, { 'error' => 'User banned because they are a very bad person'}, 200, 150)
			assert_raise(DataSift::AccessDeniedError) { @recording.update({ 'name' => 'New recording name' }) }
		end

		should "be APIError given a 404 response" do
			@user.api_client.setResponse(404, { 'error' => 'Endpoint or data not found'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.update({ 'name' => 'New recording name' }) }
		end

		should "be APIError given a 500 response" do
			@user.api_client.setResponse(500, { 'error' => 'Problem with an internal service'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.update({ 'name' => 'New recording name' }) }
		end
	end

	context "A deleted Recording object" do
		setup do
			init()
			initUser()
			@recording = DataSift::Recording.new(@user, @testdata['recording'])
			@user.api_client.setResponse(200, { 'success' => 'true'}, 200, 150)
			@recording.delete()
		end

		should "not allow the ID to be read" do
			assert_raise(DataSift::InvalidDataError) { @recording.id }
		end

		should "not allow the start_time to be read" do
			assert_raise(DataSift::InvalidDataError) { @recording.start_time }
		end

		should "not allow the end_time to be read" do
			assert_raise(DataSift::InvalidDataError) { @recording.end_time }
		end

		should "not allow the name to be read" do
			assert_raise(DataSift::InvalidDataError) { @recording.name }
		end

		should "not allow the hash to be read" do
			assert_raise(DataSift::InvalidDataError) { @recording.hash }
		end

		should "not allow a call to update" do
			assert_raise(DataSift::InvalidDataError) { @recording.update({ 'name' => 'New recording name' }) }
		end
	end

	context "The exception raised by the Recording.delete method" do
		setup do
			init()
			initUser()
			@recording = DataSift::Recording.new(@user, @testdata['recording'])
		end

		should "be APIError given a 400 response" do
			@user.api_client.setResponse(400, { 'error' => 'Bad request from user supplied data'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.delete() }
		end

		should "be AccessDenied given a 401 response" do
			@user.api_client.setResponse(401, { 'error' => 'User banned because they are a very bad person'}, 200, 150)
			assert_raise(DataSift::AccessDeniedError) { @recording.delete() }
		end

		should "be APIError given a 404 response" do
			@user.api_client.setResponse(404, { 'error' => 'Endpoint or data not found'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.delete() }
		end

		should "be APIError given a 500 response" do
			@user.api_client.setResponse(500, { 'error' => 'Problem with an internal service'}, 200, 150)
			assert_raise(DataSift::APIError) { @recording.delete() }
		end
	end
end
