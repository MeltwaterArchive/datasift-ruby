require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift' do

  before do
    auth = DataSiftExample.new
    @datasift = auth.datasift
    @data = OpenStruct.new

    @data.label = 'minitest'
    @data.token = '4b7c38dbd1b4b74046a1cc0e3081e38e'
    @data.service = 'facebook'
    @data.expires_at = 1577836800
    @data.total_allowance = 100_000
  end

  ##
  # :POST /account/identity/limit
  #
  describe 'successful :POST' do
    before do
      VCR.use_cassette('account/identity/limit/before_create_success') do
        identity = @datasift.account_identity.create(@data.label)
        @identity_id = identity[:data][:id]
      end
    end

    after do
      VCR.use_cassette('account/identity/limit/after_create_success') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_create_identity_token' do
      VCR.use_cassette('account/identity/limit/create_success') do
        response = @datasift.account_identity_limit.create(
          @identity_id,
          @data.service,
          @data.total_allowance
        )
        assert_equal STATUS.created, response[:http][:status]
      end
    end

    it 'cannot_set_limit_without_params' do
      assert_raises ArgumentError do
        @datasift.account_identity_limit.create
      end
    end

    it 'cannot_set_limit_for_invalid_service' do
      VCR.use_cassette('account/identity/limit/create_invalid_service') do
        response = @datasift.account_identity_limit.create(
          @identity_id,
          'INVALID_SERVICE',
          @data.total_allowance
        )
        assert_equal STATUS.bad_request, response[:http][:status]
      end
    end
  end

  ##
  # :GET /account/identity/limit
  #
  describe 'successful :GET' do
    before do
      VCR.use_cassette('account/identity/limit/before_get_success') do
        identity = @datasift.account_identity.create(@data.label)
        @identity_id = identity[:data][:id]
        limit = @datasift.account_identity_limit.create(
          @identity_id,
          @data.service,
          @data.total_allowance
        )
      end
    end

    after do
      VCR.use_cassette('account/identity/limit/after_get_success') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_get_limit_by_identity_id_and_service' do
      VCR.use_cassette('account/identity/limit/get_success') do
        response = @datasift.account_identity_limit.get(
          @identity_id,
          @data.service
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_list_of_limits_for_service' do
      VCR.use_cassette('account/identity/limit/list_success') do
        response = @datasift.account_identity_limit.list(
          @data.service
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_list_of_limits_with_params' do
      VCR.use_cassette('account/identity/limit/list_success_with_params') do
        response = @datasift.account_identity_limit.list(
          @data.service,
          1,
          1
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful :GET' do
    it 'cannot_get_limit_without_service' do
      assert_raises ArgumentError do
        @datasift.account_identity_limit.get
      end
    end

    it 'cannot_get_limit_for_invalid_identity' do
      VCR.use_cassette('account/identity/limit/get_failure_invalid_identity') do
        response = @datasift.account_identity_limit.get(
          'INVALID_IDENTITY_ID',
          @data.service
        )
      end
    end
  end

  ##
  # :PUT /account/identity/limit
  #
  describe 'successful :PUT' do
    before do
      VCR.use_cassette('account/identity/limit/before_successful_update') do
        identity = @datasift.account_identity.create(@data.label)
        @identity_id = identity[:data][:id]
        response = @datasift.account_identity_limit.create(
          @identity_id,
          @data.service,
          @data.total_allowance
        )
      end
    end

    after do
      VCR.use_cassette('account/identity/limit/after_successful_update') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_update_limit' do
      VCR.use_cassette('account/identity/limit/update_success') do
        response = @datasift.account_identity_limit.update(
          @identity_id,
          @data.service,
          @data.total_allowance * 2
        )
      end
      assert_equal STATUS.valid, response[:http][:status]
    end
  end

  describe 'unsuccessful :PUT' do
    it 'cannot_update_with_unknown_identity_id' do
      VCR.use_cassette('account/identity/limit/update_id_404') do
        response = @datasift.account_identity_limit.update(
          @identity_id,
          @data.service,
          @data.total_allowance * 2
        )
      end
      assert_equal STATUS.not_found, response[:http][:status]
    end

    it 'cannot_update_without_identity_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.update(
          @data.service,
          @data.total_allowance * 2
        )
      end
    end
  end

  ##
  # :DELETE /account/identity/limit
  #
  describe ':DELETE' do
    before do
      VCR.use_cassette('account/identity/limit/before_delete') do
        identity = @datasift.account_identity.create(@data.label)
        @identity_id = identity[:data][:id]
      end
    end

    after do
      VCR.use_cassette('account/identity/limit/after_delete') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_delete_identity' do
      VCR.use_cassette('account/identity/limit/delete_success') do
        response = @datasift.account_identity_limit.delete(
          @identity_id,
          @data.service
        )
      end
      assert_equal STATUS.no_content, response[:http][:status]
    end

    it 'cannot_delete_without_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_limit.delete(
          '',
          @data.service
        )
      end
    end

    it 'cannot_delete_without_service' do
      assert_raises ArgumentError do
        @datasift.account_identity_limit.delete(
          @identity_id,
          ''
        )
      end
    end
  end
end
