require './' + File.dirname(__FILE__) + '/helper'

class TestHistorics < Test::Unit::TestCase
	context "Given a new Historic object from a stream hash" do
		setup do
			init()
			# Create the historic
			@historic = @user.createHistoric(@testdata['definition_hash'], @testdata['historic_start'], @testdata['historic_end'], @testdata['historic_sources'], @testdata['historic_sample'], @testdata['historic_name'])
		end

		should "be a Historic object" do
			assert_not_nil @historic
			assert @historic.kind_of?(DataSift::Historic)
		end

		should "have the correct definition_hash" do
			assert_equal @testdata['definition_hash'], @historic.stream_hash
		end

		should "have the correct name" do
			assert_equal @testdata['historic_name'], @historic.name
		end

		should "have the correct start_date" do
			assert_equal @testdata['historic_start'], @historic.start_date
		end

		should "have the correct end_date" do
			assert_equal @testdata['historic_end'], @historic.end_date
		end

		should "have the correct status" do
			assert_equal @testdata['historic_status'], @historic.status
		end

		should "have the correct progress" do
			assert_equal 0, @historic.progress
		end

		should "have the correct sample" do
			assert_equal @testdata['historic_sample'], @historic.sample
		end

		should "be able to change the name before preparing" do
			assert_equal @testdata['historic_name'], @historic.name

			@historic.name = 'new name'

			assert_equal 'new name', @historic.name
		end

		should "be able to prepare the query" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()
		end

		should "not be able to prepare it more than once" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()
			assert_raise(DataSift::InvalidDataError) { @historic.prepare() }
		end

		should "be able to change the name after preparing" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()

			assert_equal @testdata['historic_name'], @historic.name

			new_name = 'new name'
			setResponseToASingleHistoric({ 'name' => new_name })
			@historic.name = new_name

			assert_equal new_name, @historic.name
		end

		should "be able to start the query" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()

			set204Response()
			@historic.start()
		end

		should "be able to stop the query" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()

			set204Response()
			@historic.stop()
		end

		should "be able to delete the query" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()

			set204Response()
			@historic.delete()
		end

		should "not be able to start the query after deletion" do
			setResponseToASingleHistoric({
				'dpus'         => @testdata['historic_dpus'],
				'availability' => @testdata['historic_availability']
			})
			@historic.prepare()

			set204Response()
			@historic.delete()

			assert_raise(DataSift::InvalidDataError) { @historic.start() }
		end
	end

	context "Given a new Historic object from a Definition" do
		setup do
			init()
			# Create the definition
			@definition = @user.createDefinition(@testdata['definition'])
			# Create the historic (API response is for compiling the definition)
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@historic = @definition.createHistoric(@testdata['historic_start'], @testdata['historic_end'], @testdata['historic_sources'], @testdata['historic_sample'], @testdata['historic_name'])
		end

		should "be a Historic object" do
			assert_not_nil @historic
		end

		should "have the correct definition_hash" do
			assert_equal @testdata['definition_hash'], @historic.stream_hash
		end

		should "have the correct name" do
			assert_equal @testdata['historic_name'], @historic.name
		end

		should "have the correct start_date" do
			assert_equal @testdata['historic_start'], @historic.start_date
		end

		should "have the correct end_date" do
			assert_equal @testdata['historic_end'], @historic.end_date
		end

		should "have the correct status" do
			assert_equal @testdata['historic_status'], @historic.status
		end

		should "have the correct progress" do
			assert_equal 0, @historic.progress
		end

		should "have the correct sample" do
			assert_equal @testdata['historic_sample'], @historic.sample
		end
	end

	context "Given a Historic object retrieved from the API" do
		setup do
			init()
			# Create the historic (API response is for compiling the definition)
			setResponseToASingleHistoric()
			@historic = @user.getHistoric(@testdata['historic_playback_id'])
		end

		should "be a Historic object" do
			assert_not_nil @historic
		end

		should "have the correct definition_hash" do
			assert_equal @testdata['definition_hash'], @historic.stream_hash
		end

		should "have the correct name" do
			assert_equal @testdata['historic_name'], @historic.name
		end

		should "have the correct start_date" do
			assert_equal @testdata['historic_start'], @historic.start_date
		end

		should "have the correct end_date" do
			assert_equal @testdata['historic_end'], @historic.end_date
		end

		should "have the correct status" do
			assert_equal @testdata['historic_status'], @historic.status
		end

		should "have the correct progress" do
			assert_equal 0, @historic.progress
		end

		should "have the correct sample" do
			assert_equal @testdata['historic_sample'], @historic.sample
		end

		should "not be able to prepare the query" do
			assert_raise(DataSift::InvalidDataError) { @historic.prepare() }
		end

		should "be able to change the name" do
			assert_equal @testdata['historic_name'], @historic.name

			new_name = 'new name'
			setResponseToASingleHistoric({ 'name' => new_name })
			@historic.name = new_name

			assert_equal new_name, @historic.name
		end
	end
end
