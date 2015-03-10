require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift' do

  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
    @statuses = OpenStruct.new
    @headers  = OpenStruct.new

    @data.valid_csdl    = 'interaction.content contains "test"'
    @data.invalid_csdl  = 'interaction.nonsense is not valid'
    @data.invalid_hash  = 'this_is_not_a_valid_stream_hash'
    @statuses.valid        = 200
    @statuses.bad_request  = 400
  end

  ##
  # /validate
  #
  describe '#validate' do
    it 'csdl_cant_be_nil_when_validating' do
      assert_raises InvalidParamError do
        @datasift.valid?(nil)
      end
    end

    it 'csdl_cant_be_empty_when_validating' do
      assert_raises InvalidParamError do
        @datasift.valid?('')
      end
    end

    it 'user_can_get_successful_validation_as_bool' do
      VCR.use_cassette('core/validate_success_bool') do
        assert @datasift.valid?(@data.valid_csdl), 'Valid CSDL must return true'
      end
    end

    it 'user_can_get_successful_validation_as_hash' do
      VCR.use_cassette('core/validate_success_hash') do
        validation = @datasift.valid?(@data.valid_csdl, false)
        assert_kind_of Hash, validation,
          "Successful validation will return a hash"
        assert_equal @statuses.valid, validation[:http][:status],
          "This request should have returned #{@statuses.validate_csdl} status"
      end
    end

    it 'failing_csdl_validation' do
      VCR.use_cassette('core/validate_invalid_hash') do
        assert_raises BadRequestError do
          @datasift.valid?(@data.invalid_csdl)
        end
      end
    end
  end

  ##
  # /compile
  #
  describe '#compile' do
    it 'csdl_cant_be_nil_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.compile(nil)
      end
    end

    it 'csdl_cant_be_empty_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.compile('')
      end
    end

    it 'successful_compilation_returns_hash' do
      VCR.use_cassette('core/compile_success') do
        response = @datasift.compile @data.valid_csdl
        assert_kind_of Hash, response,
          "Successful compilation will return a hash"
        assert_equal @statuses.valid, response[:http][:status],
          "This request should have returned #{@statuses.validate_csdl} status"
      end
    end
  end

  ##
  # /usage
  #
  describe '#usage' do
    it 'can_get_users_usage' do
      VCR.use_cassette('core/usage_success') do
        response = @datasift.usage
        assert_equal @statuses.valid, response[:http][:status]
        assert_kind_of Hash, response
      end
    end
  end

  ##
  # /dpu
  #
  describe '#dpu' do
    before do
      VCR.use_cassette('core/before_dpu') do
        @hash = @datasift.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    it 'can_get_dpu_cost' do
      VCR.use_cassette('core/dpu_get_cost') do
        response = @datasift.dpu @hash
        assert_equal @statuses.valid, response[:http][:status]
      end
    end

    it 'cannot_get_dpu_cost_for_invalid_hash' do
      VCR.use_cassette('core/dpu_throw_badrequest') do
        assert_raises BadRequestError do
          @datasift.dpu @data.invalid_hash
        end
      end
    end
  end

  ##
  # /balance
  #
  describe '#balance' do
    it 'can get account balance' do
      VCR.use_cassette('core/balance_get') do
        response = @datasift.balance
        assert_equal @statuses.valid, response[:http][:status]
      end
    end
  end
end
