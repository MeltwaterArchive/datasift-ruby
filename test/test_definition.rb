require 'helper'
require 'crack'

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
					'cost'       => 10,
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
				'cost'       => 10,
			}, 200, 150)
			assert_equal @testdata['definition_hash'], @definition.hash
		end

		should "have a positive cost" do
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
			}, 200, 150)
			@definition.compile()
			assert @definition.total_cost > 0
		end

		should "have a valid created_at date" do
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
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

		should "have a hash of false" do
			@user.api_client.setResponse(400, {
				'error' => 'The target interactin.content does not exist',
			}, 200, 150)
			assert_equal false, @definition.hash
		end
	end

	context "The cost returned from a valid Definition object" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile the definition first
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
			}, 200, 150)
			@definition.compile()
			# Now get the cost
			@user.api_client.setResponse(200, {
				'costs' => {
					'contains' => {
						'count'   => 1,
						'cost'    => 4,
						'targets' => {
							'interaction.content' => {
								'count' => 1,
								'cost'  => 4,
							},
						},
					},
				},
				'total' => 4
			}, 200, 150)
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
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile the definition first
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
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
				'cost'       => 10,
			}, 200, 150)
			@definition.compile()
			# Now get a consumer
			@consumer = @definition.getConsumer()
		end

		should "be valid" do
			assert @consumer.is_a? DataSift::StreamConsumer
		end
	end

	context "Given a valid Definition object, calling getUsage" do
		setup do
			init()
			initUser()
			@definition = @user.createDefinition(@testdata['definition'])
			# Compile it so we have the hash
			@user.api_client.setResponse(200, {
				'hash'       => @testdata['definition_hash'],
				'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
				'cost'       => 10,
			}, 200, 150)
			@definition.compile()
		end

		should "return valid usage information" do
			@user.api_client.setResponse(200, Crack::JSON.parse('{"processed":2494,"delivered":2700,"types":{"buzz":{"processed":247,"delivered":350},"twitter":{"processed":2247,"delivered":2350}}}'), 200, 150)
			usage = @definition.getUsage()
			assert_equal 2494, usage['processed']
			assert_equal 2700, usage['delivered']
			assert_equal 247, usage['types']['buzz']['processed']
			assert_equal 350, usage['types']['buzz']['delivered']
			assert_equal 2247, usage['types']['twitter']['processed']
			assert_equal 2350, usage['types']['twitter']['delivered']
		end
	end
end
