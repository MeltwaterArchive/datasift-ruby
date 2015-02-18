require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift' do
  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
    @statuses = OpenStruct.new
    @headers  = OpenStruct.new

    @data.valid_csdl    = 'interaction.content contains "test"'
    @data.vedo_csdl     = 'tag.keyword "test" { interaction.content contains "test" }
    tag.score 1 { interaction.content contains "test" }
    return { interaction.content contains "test" }'
    @data.invalid_csdl  = 'interaction.nonsense is not valid'
    @data.invalid_hash  = 'abc_invalid_hash_123'

    @statuses.valid        = 200
    @statuses.valid_empty  = 204
    @statuses.bad_request  = 400
    @statuses.not_found    = 404
  end

  ##
  # /analysis/validate
  #
  describe '#analysis/validate' do
    it 'csdl_cant_be_nil_when_validating' do
      assert_raises InvalidParamError do
        @datasift.analysis.valid?(nil)
      end
    end

    it 'csdl_cant_be_empty_when_validating' do
      assert_raises InvalidParamError do
        @datasift.analysis.valid?('')
      end
    end

    it 'if_user_can_get_successful_validation_as_bool' do
      VCR.use_cassette('analysis_validate_success_bool') do
        assert @datasift.analysis.valid?(@data.valid_csdl)
      end
    end

    it 'if_user_can_get_successful_validation_as_hash' do
      VCR.use_cassette('analysis_validate_success_hash') do
        response = @datasift.analysis.valid?(@data.valid_csdl, false)
        assert_kind_of Hash, response, 'Valid should return a Ruby hash here'
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'failing_csdl_validation' do
      VCR.use_cassette('analysis_validate_invalid_hash') do
        assert_raises BadRequestError do
          @datasift.analysis.valid?(@data.invalid_csdl)
        end
      end
    end
  end

  ##
  # /analysis/compile
  #
  describe '#analysis/compile' do
    it 'csdl_cant_be_nil_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.analysis.compile(nil)
      end
    end

    it 'csdl_cant_be_empty_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.analysis.compile('')
      end
    end

    it 'if_user_can_successfully_compile_valid_csdl' do
      VCR.use_cassette('analysis_compile_valid_csdl_compilation') do
        response = @datasift.analysis.compile @data.valid_csdl
        assert_kind_of Hash, response, 'Valid should return a Ruby hash here'
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'invalid_csdl_fails_compilation' do
      VCR.use_cassette('analysis_compile_invalid_csdl_compilation') do
        assert_raises BadRequestError do
          @datasift.analysis.valid?(@data.invalid_csdl)
        end
      end
    end
  end

  ##
  # /analysis/get
  #
  describe 'successful #analysis/get' do
    before do
      VCR.use_cassette('before_analysis_get') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
        @datasift.analysis.start(@hash, 'ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('after_analysis_get') do
        @datasift.analysis.stop @hash
      end
    end

    it 'can_get_list' do
      VCR.use_cassette('analysis_get_list') do
        response = @datasift.analysis.get
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'can_get_by_hash' do
      VCR.use_cassette('analysis_get_by_hash') do
        response = @datasift.analysis.get @hash
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'cannot_get_by_invalid_hash' do
      VCR.use_cassette('analysis_get_by_invalid_hash') do
        assert_raises ApiResourceNotFoundError do
          @datasift.analysis.get @data.invalid_hash
        end
      end
    end
  end

  ##
  # /analysis/start
  #
  describe 'successful #analysis/start' do
    before do
      VCR.use_cassette('before_successful_analysis_start') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    after do
      VCR.use_cassette('after_successful_analysis_start') do
        @datasift.analysis.stop @hash
      end
    end

    it 'can_start_valid_hash' do
      VCR.use_cassette('analysis_start_valid_hash') do
        response = @datasift.analysis.start(@hash, 'ruby-lib-test')
        assert_equal @statuses.valid_empty, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #analysis/start' do
    before do
      VCR.use_cassette('before_unsuccessful_analysis_start') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    it 'cannot_start_valid_hash_with_no_name' do
      VCR.use_cassette('analysis_start_valid_hash_no_name') do
        assert_raises ArgumentError do
          @datasift.analysis.start(@hash)
        end
      end
    end

    it 'cannot_start_with_no_params' do
      VCR.use_cassette('analysis_start_no_params') do
        assert_raises ArgumentError do
          @datasift.analysis.start
        end
      end
    end

    it 'cannot_start_invalid_hash' do
      VCR.use_cassette('analysis_start_invalid_hash') do
        assert_raises BadRequestError do
          @datasift.analysis.start(@data.invalid_hash, 'ruby-lib-test')
        end
      end
    end
  end

  ##
  # /analysis/stop
  #
  describe 'successful #analysis/stop' do
    before do
      VCR.use_cassette('before_successful_analysis_stop') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
        @datasift.analysis.start(@hash, 'ruby-lib-test')
      end
    end

    it 'can_stop_valid_hash' do
      VCR.use_cassette('analysis_stop_valid_hash') do
        response = @datasift.analysis.stop @hash
        assert_equal @statuses.valid_empty, response[:http][:status]
      end
    end
  end

  describe 'conflicting #analysis/stop' do
    before do
      VCR.use_cassette('before_conflicting_analysis_stop') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
        @datasift.analysis.start(@hash, 'ruby-lib-test')
      end
    end

    it 'cannot_stop_stopped_hash' do
      VCR.use_cassette('analysis_stop_stopped_hash') do
        @datasift.analysis.stop @hash
        assert_raises ConflictError do
          @datasift.analysis.stop @hash
        end
      end
    end
  end

  describe 'nothing to stop #analysis/stop' do
    it 'cannot_stop_invalid_hash' do
      VCR.use_cassette('analysis_stop_invalid_hash') do
        assert_raises BadRequestError do
          @datasift.analysis.stop @data.invalid_hash
        end
      end
    end

    it 'cannot_stop_missing_hash' do
      assert_raises ArgumentError do
        @datasift.analysis.stop
      end
    end
  end

  ##
  # /analysis/analyze
  #
  describe '#analysis/analyze' do
    before do
      VCR.use_cassette('before_analysis_analyze') do
        @hash = @datasift.analysis.compile(@data.valid_csdl)[:data][:hash]
        @datasift.analysis.start(@hash, 'ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('after_analysis_analyze') do
        @datasift.analysis.stop @hash
      end
    end

    it 'can_freq_dist_valid' do
      VCR.use_cassette('analysis_analyze_freq_dist') do
        params = {
          :analysis_type => "freqDist",
          :parameters => {
            :threshold => 1,
            :target => "fb.author.country"
          }
        }
        response = @datasift.analysis.analyze(@hash, params)
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'can_time_series_valid' do
      VCR.use_cassette('analysis_analyze_time_series') do
        params = {
          :analysis_type => "timeSeries",
          :parameters => {
            :interval => "hour",
            :span => 12
          }
        }
        response = @datasift.analysis.analyze(@hash, params)
        assert_equal @statuses.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #analysis/analyze' do
    it 'cannot_analyze_invalid_hash' do
      VCR.use_cassette('analysis_analyze_invalid_hash') do
        params = {
          :analysis_type => "freqDist",
          :parameters => {
            :threshold => 1,
            :target => "fb.author.country"
          }
        }
        assert_raises BadRequestError do
          @datasift.analysis.analyze(@data.invalid_hash, params)
        end
      end
    end

    it 'cannot_analyze_missing_hash_and_params' do
      assert_raises ArgumentError do
        @datasift.analysis.analyze
      end
    end
  end

  ##
  # /analysis/tags
  #
  describe 'successful #analysis/tags' do
    before do
      VCR.use_cassette('before_analysis_tags') do
        @vedohash = @datasift.analysis.compile(@data.vedo_csdl)[:data][:hash]
        @datasift.analysis.start(@vedohash, 'vedo-ruby-lib-test')
      end
    end

    after do
      VCR.use_cassette('after_analysis_tags') do
        @datasift.analysis.stop @vedohash
      end
    end

    it 'can_analyze_tags' do
      VCR.use_cassette('analysis_tags_vedo_csdl') do
        response = @datasift.analysis.tags @vedohash
        assert_equal @statuses.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful #analysis/tags' do
    it 'cannot_analyze_tags_with_missing_hash' do
      assert_raises ArgumentError do
        @datasift.analysis.tags
      end
    end
  end
end










