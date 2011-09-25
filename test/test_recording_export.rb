require 'helper'

class TestRecordingExport < Test::Unit::TestCase
	context "A valid RecordingExport object created from an array" do
		setup do
			init()
			initUser()
			@export = DataSift::RecordingExport.new(@user, @testdata['export'])
		end

		should "contain the correct data" do
			assert_equal @testdata['export']['id'], @export.id
			assert_equal @testdata['export']['recording_id'], @export.recording_id
			assert_equal @testdata['export']['start'], @export.start_time
			assert_equal @testdata['export']['end'], @export.end_time
			assert_equal @testdata['export']['name'], @export.name
			assert_equal @testdata['export']['status'], @export.status
		end
	end

	context "A valid RecordingExport object created from an ID" do
		setup do
			init()
			initUser()
			@user.api_client.setResponse(200, @testdata['export'], 200, 150)
			@export = DataSift::RecordingExport.new(@user, @testdata['export']['id'])
		end

		should "contain the correct data" do
			assert_equal @testdata['export']['id'], @export.id
			assert_equal @testdata['export']['recording_id'], @export.recording_id
			assert_equal @testdata['export']['start'], @export.start_time
			assert_equal @testdata['export']['end'], @export.end_time
			assert_equal @testdata['export']['name'], @export.name
			assert_equal @testdata['export']['status'], @export.status
		end
	end

	context "A deleted RecordingExport object" do
		setup do
			init()
			initUser()
			@export = DataSift::RecordingExport.new(@user, @testdata['export'])
			@user.api_client.setResponse(200, { 'success' => 'true'}, 200, 150)
			@export.delete()
		end

		should "not allow the ID to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.id }
		end

		should "not allow the recording_id to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.recording_id }
		end

		should "not allow the start_time to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.start_time }
		end

		should "not allow the end_time to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.end_time }
		end

		should "not allow the name to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.name }
		end

		should "not allow the status to be read" do
			assert_raise(DataSift::InvalidDataError) { @export.status }
		end
	end

	context "The exception raised by the RecordingExport.delete method" do
		setup do
			init()
			initUser()
			@export = DataSift::RecordingExport.new(@user, @testdata['export'])
		end

		should "be APIError given a 400 response" do
			@user.api_client.setResponse(400, { 'error' => 'Bad request from user supplied data'}, 200, 150)
			assert_raise(DataSift::APIError) { @export.delete() }
		end

		should "be AccessDenied given a 401 response" do
			@user.api_client.setResponse(401, { 'error' => 'User banned because they are a very bad person'}, 200, 150)
			assert_raise(DataSift::AccessDeniedError) { @export.delete() }
		end

		should "be APIError given a 404 response" do
			@user.api_client.setResponse(404, { 'error' => 'Endpoint or data not found'}, 200, 150)
			assert_raise(DataSift::APIError) { @export.delete() }
		end

		should "be APIError given a 500 response" do
			@user.api_client.setResponse(500, { 'error' => 'Problem with an internal service'}, 200, 150)
			assert_raise(DataSift::APIError) { @export.delete() }
		end
	end
end
