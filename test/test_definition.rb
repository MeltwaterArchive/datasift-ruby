require 'helper'

class TestDefinition < Test::Unit::TestCase
	context "Given an empty Definition object" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition()
		end

		should "have an empty CSDL" do
			assert_not_nil @definition
			assert_equal '', @definition.csdl
		end

		should "correctly set and get the CSDL" do
			@definition.csdl = @testdata['definition']
			assert_equal @testdata['definition'], @definition.csdl
		end
	end

	context "Given a Definition object with CSDL" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
		end

		should "have the correct CSDL" do
			assert_not_nil @definition
			assert_equal @testdata['definition'], @definition.csdl
		end
	end

	context "Given a Definition object with CSDL plus padding" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition("    " + @testdata['definition'] + "     ")
		end

		should "have the correct CSDL" do
			assert_not_nil @definition
			assert_equal @testdata['definition'], @definition.csdl
		end
	end

	context "When trying to create a Definition object with an invalid user" do
		should "raise an InvalidDataError" do
			assert_raise(DataSift::InvalidDataError) { DataSift::Definition.new('username') }
		end
	end

	context "When trying to create a Definition object with an invalid CSDL" do
		setup do
			init()
			initUser()
		end

		should "raise an InvalidDataError" do
			assert_raise(DataSift::InvalidDataError) { DataSift::Definition.new(@user, 1234) }
		end
	end

	context "Given a Definition object with a valid CSDL" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
		end

		should "compile the definition successfully" do
			begin
				@user.api_client.setResponse(200, {
					'hash'       => @testdata['definition_hash'],
					'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
					'dpu'       => 10,
				}, 200, 150)
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
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			assert_equal @testdata['definition_hash'], @definition.hash
		end

		should "have a positive DPU" do
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@definition.compile()
			assert @definition.total_dpu > 0
		end

		should "have a valid created_at date" do
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@definition.compile()
			assert @definition.created_at
		end
	end

	context "Given a Definition object with an invalid CSDL" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['invalid_definition'])
		end

		should "fail to compile the definition" do
			@user.api_client.setResponse(400, {
				'error' => 'The target interactin.content does not exist',
			}, 200, 150)
			assert_raise(DataSift::CompileFailedError) { @definition.compile() }
		end

		should "fail to get the hash" do
			@user.api_client.setResponse(400, {
				'error' => 'The target interactin.content does not exist',
			}, 200, 150)
			assert_raise(DataSift::CompileFailedError) { @definition.hash }
		end
	end

	context "The DPU returned from a valid Definition object" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile the definition first
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@definition.compile()
			# Now get the DPU
			@user.api_client.setResponse(200, {
				'detail' => {
					'contains' => {
						'count'   => 1,
						'dpu'     => 4,
						'targets' => {
							'interaction.content' => {
								'count' => 1,
								'dpu'   => 4,
							},
						},
					},
				},
				'dpu' => 4
			}, 200, 150)
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
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile the definition first
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@definition.compile()
			# Now get some buffered interactions
			@user.api_client.setResponse(200, {
				'stream' => {
					0 => {
						'interaction' => {
							'source' => 'Snaptu',
							'author' => {
								'username' => 'nittolexia',
								'name'     => 'nittosoetreznoe',
								'id'       => 172192091,
								'avatar'   => 'http://a0.twimg.com/profile_images/1429378181/gendowor_normal.jpg',
								'link'     => 'http://twitter.com/nittolexia',
							},
							'type'       => 'twitter',
							'link'       => 'http://twitter.com/nittolexia/statuses/89571192838684672',
							'created_at' => 'Sat, 09 Jul 2011 05:46:51 +0000',
							'content'    => 'RT @ayyuchadel: Haha RT @nittolexia: Mending gak ush maen twitter dehh..RT @sansan_arie:',
							'id'         => '1e0a9eedc207acc0e074ea8aecb2c5ea',
						},
						'twitter' => {
							'user' => {
								'name'            => 'nittosoetreznoe',
								'description'     => 'fuck all',
								'location'        => 'denpasar, bali',
								'statuses_count'  => 6830,
								'followers_count' => 88,
								'friends_count'   => 111,
								'screen_name'     => 'nittolexia',
								'lang'            => 'en',
								'time_zone'       => 'Alaska',
								'id'              => 172192091,
								'geo_enabled'     => true,
							},
							'mentions' => {
								0 => 'ayyuchadel',
								1 => 'nittolexia',
								2 => 'sansan_arie',
							},
							'id'         => '89571192838684672',
							'text'       => 'RT @ayyuchadel: Haha RT @nittolexia: Mending gak ush maen twitter dehh..RT @sansan_arie:',
							'source'     => '<a href="http://www.snaptu.com" rel="nofollow">Snaptu</a>',
							'created_at' => 'Sat, 09 Jul 2011 05:46:51 +0000',
						},
						'klout' => {
							'score'         => 45,
							'network'       => 55,
							'amplification' => 17,
							'true_reach'    => 31,
							'slope'         => 0,
							'class'         => 'Networker',
						},
						'peerindex' => {
							'score' => 30,
						},
						'language' => {
							'tag' => 'da',
						},
					},
				},
			}, 200, 150)
			@interactions = @definition.getBuffered()
		end

		should "be valid" do
			assert @interactions
		end
	end

	context "A StreamConsumer object returned by a valid Definition object" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile the definition first
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'dpu'        => 10,
			}, 200, 150)
			@definition.compile()
			# Now get a consumer
			@consumer = @definition.getConsumer()
		end

		should "be valid" do
			assert @consumer.is_a? DataSift::StreamConsumer
		end
	end
end
