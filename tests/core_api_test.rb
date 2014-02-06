require '../examples/auth'
require 'test/unit'
require 'webmock/test_unit'
require 'multi_json'
class CoreApiTest < Test::Unit::TestCase

  def setup
    auth       = DataSiftExample.new
    @datasift  = auth.datasift
    @data      = OpenStruct.new
    @responses = OpenStruct.new
    @statuses  = OpenStruct.new
    @headers   = OpenStruct.new

    @data.valid_csdl        = 'interaction.content contains "test"'
    @data.invalid_csdl      = 'interaction.nonsense is not valid'
    #{"created_at" => "2014-01-30 10:09:19", "dpu" => "0.1"}
    @responses.valid_csdl   = '{"created_at": "2014-01-30 10:09:19","dpu": "0.1"}'
    @responses.invalid_csdl = '{"error": "The target interaction.nonsense does not exist"}'
    @responses.valid_stream = OpenStruct.new({:hash => '145ea24a4d83a14ecb9077b831f14809', :created_at => '2014-01-30 17:35:14', :dpu => '0.1'})

    @statuses.valid_csdl   = 200
    @statuses.invalid_csdl = 400

    @headers.valid_csdl = {
        "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
        "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
        "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "5"}
    #valid CSDL
    stub_request(:post, /api.datasift.com\/.*\/validate/).
        with(:body => {"csdl" => @data.valid_csdl}).
        to_return(:status  => @statuses.valid_csdl,
                  :body    => @responses.valid_csdl,
                  :headers => @headers.valid_csdl)
    #invalid CSDL
    stub_request(:post, /api.datasift.com\/.*\/validate/).
        with(:body => {"csdl" => @data.invalid_csdl}).
        to_return(:status  => @statuses.invalid_csdl,
                  :body    => @responses.invalid_csdl,
                  :headers => @headers.valid_csdl)
    #valid stream compilation
    stub_request(:post, /api.datasift.com\/.*\/compile/).
        with(:body => {"csdl" => @data.valid_csdl}).
        to_return(:status  => @statuses.valid_csdl,
                  :body    => MultiJson.dump(@responses.valid_stream),
                  :headers => @headers.valid_csdl)

  end


  def teardown
    # Do nothing
  end

  def test_csdl_cant_be_nil_when_validating
    assert_raise InvalidParamError do
      @datasift.valid?(nil)
    end
  end

  def test_csdl_cant_be_empty_when_validating
    assert_raise InvalidParamError do
      @datasift.valid?('')
    end
  end

  def test_if_user_can_get_successful_validation_as_bool
    assert_boolean @datasift.valid?(@data.valid_csdl), 'Valid must return a bool by default'
    assert_true @datasift.valid?(@data.valid_csdl), 'This request should have returned true'
  end

  def test_if_user_can_get_successful_validation_as_hash
    validation = @datasift.valid?(@data.valid_csdl, false)
    assert_kind_of Hash, validation, 'Valid should return a hash here'
    assert_equal @statuses.valid_csdl, validation[:http][:status], "This request should have returned status as #{@statuses.validate_csdl}"
  end

  def test_failing_csdl_validation
    assert_raise BadRequestError do
      @datasift.valid?(@data.invalid_csdl)
    end
  end

  def test_csdl_cant_be_nil_when_compiling
    assert_raise InvalidParamError do
      @datasift.compile(nil)
    end
  end

  def test_csdl_cant_be_empty_when_compiling
    assert_raise InvalidParamError do
      @datasift.compile('')
    end
  end
end
