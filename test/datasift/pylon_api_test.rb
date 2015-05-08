require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift' do
  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new

    @data.valid_csdl = 'interaction.content contains "ruby"'
    @data.vedo_csdl = "tag.keyword \"ruby\" { interaction.content contains_any \"ruby\, #{Time.now}\" }
    tag.score 1 { interaction.content contains \"ruby\" }
    return { interaction.content contains \"ruby\" }"
    @data.invalid_csdl = 'interaction.nonsense is not valid'
    @data.invalid_filter = 'abc_invalid_filter_123'
  end

  ##
  # /pylon/validate
  #
  describe '#pylon/validate' do
    it 'csdl_cant_be_nil_when_validating' do
      assert_raises InvalidParamError do
        @datasift.pylon.valid?(csdl: nil)
      end
    end

    it 'csdl_cant_be_empty_when_validating' do
      assert_raises InvalidParamError do
        @datasift.pylon.valid?(csdl: '')
      end
    end

    it 'if_user_can_get_successful_validation_as_bool' do
      VCR.use_cassette('pylon/pylon_validate_success_bool') do
        assert @datasift.pylon.valid?(csdl: @data.valid_csdl)
      end
    end

    it 'if_user_can_get_successful_validation_as_filter' do
      VCR.use_cassette('pylon/pylon_validate_success_filter') do
        response = @datasift.pylon.valid?(
          csdl: @data.valid_csdl, boolResponse: false
        )
        assert_kind_of Hash, response, 'Valid should return a Ruby hash here'
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'failing_csdl_validation' do
      VCR.use_cassette('pylon/pylon_validate_invalid_filter') do
        assert_raises BadRequestError do
          @datasift.pylon.valid?(csdl: @data.invalid_csdl)
        end
      end
    end
  end

  ##
  # /pylon/compile
  #
  describe '#pylon/compile' do
    it 'csdl_cant_be_nil_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.pylon.compile(nil)
      end
    end

    it 'csdl_cant_be_empty_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.pylon.compile('')
      end
    end

    it 'if_user_can_successfully_compile_valid_csdl' do
      VCR.use_cassette('pylon/pylon_compile_valid_csdl_compilation') do
        response = @datasift.pylon.compile @data.valid_csdl
        assert_kind_of Hash, response, 'Valid should return a Ruby hash here'
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'invalid_csdl_fails_compilation' do
      VCR.use_cassette('pylon/pylon_compile_invalid_csdl_compilation') do
        assert_raises BadRequestError do
          @datasift.pylon.valid?(@data.invalid_csdl)
        end
      end
    end
  end

  ##
  # /pylon/get
  #
  describe 'successful #pylon/get' do
    before do
      VCR.use_cassette('pylon/before_pylon_get') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
        @datasift.pylon.start(hash: @filter, name: 'ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('pylon/after_pylon_get') do
        @datasift.pylon.stop @filter
      end
    end

    it 'can_get_list' do
      VCR.use_cassette('pylon/pylon_get_list') do
        response = @datasift.pylon.list
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_paginated_list' do
      VCR.use_cassette('pylon/pylon_get_paginated_list') do
        response = @datasift.pylon.list(page: 1, per_page: 1)
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_by_filter' do
      VCR.use_cassette('pylon/pylon_get_by_filter') do
        response = @datasift.pylon.get @filter
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'cannot_get_by_invalid_filter' do
      VCR.use_cassette('pylon/pylon_get_by_invalid_filter') do
        assert_raises ApiResourceNotFoundError do
          @datasift.pylon.get @data.invalid_filter
        end
      end
    end
  end

  ##
  # /pylon/start
  #
  describe 'successful #pylon/start' do
    before do
      VCR.use_cassette('pylon/before_successful_pylon_start') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    after do
      VCR.use_cassette('pylon/after_successful_pylon_start') do
        @datasift.pylon.stop @filter
      end
    end

    it 'can_start_valid_filter' do
      VCR.use_cassette('pylon/pylon_start_valid_filter') do
        response = @datasift.pylon.start(hash: @filter, name: 'ruby-lib-test')
        assert_equal STATUS.valid_empty, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #pylon/start' do
    before do
      VCR.use_cassette('pylon/before_unsuccessful_pylon_start') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    it 'cannot_start_with_no_params' do
      VCR.use_cassette('pylon/pylon_start_no_params') do
        assert_raises ArgumentError do
          @datasift.pylon.start
        end
      end
    end

    it 'cannot_start_invalid_filter' do
      VCR.use_cassette('pylon/pylon_start_invalid_filter') do
        assert_raises BadRequestError do
          @datasift.pylon.start(
            hash: @data.invalid_filter, name: 'ruby-lib-test'
          )
        end
      end
    end
  end

  describe 'unsuccessful #pylon/start unique filter' do
    before do
      VCR.use_cassette('pylon/before_unsuccessful_pylon_start_unique_filter') do
        csdl = "interaction.content any \"#{Time.now}\""
        @filter = @datasift.pylon.compile(csdl)[:data][:hash]
      end
    end

    it 'cannot_start_valid_filter_with_no_name' do
      VCR.use_cassette('pylon/pylon_start_valid_filter_no_name') do
        assert_raises BadRequestError do
          @datasift.pylon.start(hash: @filter)
        end
      end
    end
  end

  ##
  # /pylon/stop
  #
  describe 'successful #pylon/stop' do
    before do
      VCR.use_cassette('pylon/before_successful_pylon_stop') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
        @datasift.pylon.start(hash: @filter, name: 'ruby-lib-test')
      end
    end

    it 'can_stop_valid_filter' do
      VCR.use_cassette('pylon/pylon_stop_valid_filter') do
        response = @datasift.pylon.stop @filter
        assert_equal STATUS.valid_empty, response[:http][:status]
      end
    end
  end

  describe 'conflicting #pylon/stop' do
    before do
      VCR.use_cassette('pylon/before_conflicting_pylon_stop') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
        @datasift.pylon.start(hash: @filter, name: 'ruby-lib-test')
      end
    end

    it 'cannot_stop_stopped_filter' do
      VCR.use_cassette('pylon/pylon_stop_stopped_filter') do
        @datasift.pylon.stop @filter
        assert_raises ConflictError do
          @datasift.pylon.stop @filter
        end
      end
    end
  end

  describe 'nothing to stop #pylon/stop' do
    it 'cannot_stop_invalid_filter' do
      VCR.use_cassette('pylon/pylon_stop_invalid_filter') do
        assert_raises BadRequestError do
          @datasift.pylon.stop @data.invalid_filter
        end
      end
    end

    it 'cannot_stop_missing_filter' do
      assert_raises ArgumentError do
        @datasift.pylon.stop
      end
    end
  end

  ##
  # /pylon/analyze
  #
  describe '#pylon/analyze' do
    before do
      VCR.use_cassette('pylon/before_pylon_analyze') do
        @filter = @datasift.pylon.compile(@data.valid_csdl)[:data][:hash]
        @datasift.pylon.start(hash: @filter, name: 'ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('pylon/after_pylon_analyze') do
        @datasift.pylon.stop @filter
      end
    end

    it 'can_freq_dist_valid' do
      VCR.use_cassette('pylon/pylon_analyze_freq_dist') do
        params = {
          :analysis_type => "freqDist",
          :parameters => {
            :threshold => 1,
            :target => "fb.author.country"
          }
        }
        response = @datasift.pylon.analyze(hash: @filter, parameters: params)
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_time_series_valid' do
      VCR.use_cassette('pylon/pylon_analyze_time_series') do
        params = {
          :analysis_type => "timeSeries",
          :parameters => {
            :interval => "hour",
            :span => 12
          }
        }
        response = @datasift.pylon.analyze(hash: @filter, parameters: params)
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #pylon/analyze' do
    it 'cannot_analyze_invalid_filter' do
      VCR.use_cassette('pylon/pylon_analyze_invalid_filter') do
        params = {
          :analysis_type => "freqDist",
          :parameters => {
            :threshold => 1,
            :target => "fb.author.country"
          }
        }
        assert_raises BadRequestError do
          @datasift.pylon.analyze(
            hash: @data.invalid_filter, parameters: params
          )
        end
      end
    end

    it 'cannot_analyze_missing_filter_and_params' do
      assert_raises ArgumentError do
        @datasift.pylon.analyze
      end
    end
  end

  ##
  # /pylon/tags
  #
  describe 'successful #pylon/tags' do
    before do
      VCR.use_cassette('pylon/before_pylon_tags') do
        @vedofilter = @datasift.pylon.compile(@data.vedo_csdl)[:data][:hash]
        @datasift.pylon.start(hash: @vedofilter, name: 'vedo-ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('pylon/after_pylon_tags') do
        @datasift.pylon.stop @vedofilter
      end
    end

    it 'can_analyze_tags' do
      VCR.use_cassette('pylon/pylon_tags_vedo_csdl') do
        response = @datasift.pylon.tags @vedofilter
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #pylon/tags' do
    it 'cannot_analyze_tags_with_missing_filter' do
      assert_raises ArgumentError do
        @datasift.pylon.tags
      end
    end
  end
end
