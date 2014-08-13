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

    @statuses.valid        = 200
    @statuses.bad_request  = 400

  end

  describe '#compile/validate' do
    before do
      @headers.csdl_compile = {
          "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
          "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
          "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "5"}

      #valid CSDL
      stub_request(:post, /api.datasift.com\/.*\/validate/).
          with(:body => {"csdl" => @data.valid_csdl}).
          to_return(:status  => @statuses.valid,
                    :body    => fixture('validate_csdl_valid.json'),
                    :headers => @headers.csdl_compile)
      #invalid CSDL
      stub_request(:post, /api.datasift.com\/.*\/validate/).
          with(:body => {"csdl" => @data.invalid_csdl}).
          to_return(:status  => @statuses.bad_request,
                    :body    => fixture('validate_csdl_invalid.json'),
                    :headers => @headers.csdl_compile)
      #valid stream compilation
      stub_request(:post, /api.datasift.com\/.*\/compile/).
          with(:body => {"csdl" => @data.valid_csdl}).
          to_return(:status  => @statuses.valid,
                    :body    => fixture('compile_csdl_valid.json'),
                    :headers => @headers.csdl_compile)
    end

    it 'test_csdl_cant_be_nil_when_validating' do
      assert_raises InvalidParamError do
        @datasift.valid?(nil)
      end
    end

    it 'test_csdl_cant_be_empty_when_validating' do
      assert_raises InvalidParamError do
        @datasift.valid?('')
      end
    end

    it 'test_if_user_can_get_successful_validation_as_bool' do
      assert @datasift.valid?(@data.valid_csdl), 'Valid CSDL must return true'
    end

    it 'test_if_user_can_get_successful_validation_as_hash' do
      validation = @datasift.valid?(@data.valid_csdl, false)
      assert_kind_of Hash, validation, 'Valid should return a hash here'
      assert_equal @statuses.valid, validation[:http][:status], "This request should have returned status as #{@statuses.validate_csdl}"
    end

    it 'test_failing_csdl_validation' do
      assert_raises BadRequestError do
        @datasift.valid?(@data.invalid_csdl)
      end
    end

    it 'test_csdl_cant_be_nil_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.compile(nil)
      end
    end

    it 'test_csdl_cant_be_empty_when_compiling' do
      assert_raises InvalidParamError do
        @datasift.compile('')
      end
    end
  end

  describe '#usage' do
    describe 'with valid request' do
      before do
        @headers.valid_usage = {
            "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
            "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
            "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "25"}

        #valid /usage request
        stub_request(:post, /api.datasift.com\/.*\/usage/).
            with(:body => {:period => 'hour'}).
            to_return(status:  @statuses.valid,
                      body:    fixture('usage_current.json'),
                      headers: @headers.valid_usage)
      end

      it 'can get users usage' do
        @datasift.usage
        assert_requested(:post, "https://api.datasift.com/v1/usage", :body => {"period"=>"hour"})
      end
    end
  end

  describe '#dpu' do
    before do
      @data.dpu_hash_valid = '145ea24a4d83a14ecb9077b831f14809'
      @headers.dpu = {
          "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
          "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
          "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "5"}

      #valid /dpu request
      stub_request(:post, /api.datasift.com\/.*\/dpu/).
          with(:body => {:hash => @data.dpu_hash_valid}).
          to_return(status:  @statuses.valid,
                    body:    fixture('dpu_valid.json'),
                    headers: @headers.dpu)
    end

    it 'can get dpu cost for valid stream' do
      @datasift.dpu(@data.dpu_hash_valid)
      assert_requested(:post, "https://api.datasift.com/v1/dpu", body: {hash: @data.dpu_hash_valid})
    end
  end

  describe '#balance' do
    before do
      @headers.balance = {
          "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
          "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
          "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "25"}

      #valid /dpu request
      stub_request(:post, /api.datasift.com\/.*\/balance/).
          to_return(status:  @statuses.valid,
                    body:    fixture('balance.json'),
                    headers: @headers.balance)
    end

    it 'can get account balance' do
      @datasift.balance
      assert_requested(:post, "https://api.datasift.com/v1/balance")
    end
  end

end
