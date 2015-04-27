require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift' do

  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new

    @data.label       = 'minitest'
    @data.token       = '4b7c38dbd1b4b74046a1cc0e3081e38e'
    @data.service     = 'facebook'
    @data.expires_at  = 1577836800
  end

  ##
  # :POST /account/identity/token
  #
  describe 'successful :POST' do
    before do
      VCR.use_cassette('account/identity/token/before_create_success') do
        identity = @datasift.account_identity.create(label: @data.label)
        @identity_id = identity[:data][:id]
      end
    end

    after do
      VCR.use_cassette('account/identity/token/after_create_success') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_create_identity_token' do
      VCR.use_cassette('account/identity/token/create_success') do
        response = @datasift.account_identity_token.create(
          identity_id: @identity_id,
          service: @data.service,
          token: @data.token,
          expires_at: @data.expires_at
        )
        assert_equal STATUS.created, response[:http][:status]
      end
    end

    it 'cannot_create_identity_without_params' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.create
      end
    end

    it 'cannot_create_identity_for_invalid_service' do
      VCR.use_cassette('account/identity/token/create_invalid_service') do
        response = @datasift.account_identity_token.create(
          identity_id: @identity_id,
          service: 'INVALID_SERVICE',
          token: @data.token,
          expires_at: @data.expires_at
        )
        assert_equal STATUS.bad_request, response[:http][:status]
      end
    end
  end

  ##
  # :GET /account/identity/token
  #
  describe 'successful :GET' do
    before do
      VCR.use_cassette('account/identity/token/before_get_success') do
        identity = @datasift.account_identity.create(label: @data.label)
        @identity_id = identity[:data][:id]
        token = @datasift.account_identity_token.create(
          identity_id: @identity_id,
          service: @data.service,
          token: @data.token,
          expires_at: @data.expires_at
        )
      end
    end

    after do
      VCR.use_cassette('account/identity/token/after_get_success') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_get_token_by_identity_id_and_service' do
      VCR.use_cassette('account/identity/token/get_success') do
        response = @datasift.account_identity_token.get(
          identity_id: @identity_id,
          service: @data.service
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_list_of_tokens_for_identity' do
      VCR.use_cassette('account/identity/token/list_success') do
        response = @datasift.account_identity_token.list(
          identity_id: @identity_id
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can_get_list_of_tokens_with_params' do
      VCR.use_cassette('account/identity/token/list_success_with_params') do
        response = @datasift.account_identity_token.list(
          identity_id: @identity_id,
          per_page: 1,
          page: 1
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  describe 'unsuccessful :GET' do
    it 'cannot_get_tokens_without_identity_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.get
      end
    end

    it 'cannot_get_tokens_for_invalid_identity' do
      VCR.use_cassette('account/identity/token/get_failure_invalid_identity') do
        response = @datasift.account_identity_token.get(
          identity_id: 'INVALID_IDENTITY_ID',
          service: @data.service
        )
      end
    end

    it 'cannot_list_tokens_without_identity_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.list
      end
    end
  end

  ##
  # :PUT /account/identity/token
  #
  describe 'successful :PUT' do
    before do
      VCR.use_cassette('account/identity/token/before_successful_update') do
        identity = @datasift.account_identity.create(label: @data.label)
        @identity_id = identity[:data][:id]
        response = @datasift.account_identity_token.create(
          identity_id: @identity_id,
          service: @data.service,
          token: @data.token,
          expires_at: @data.expires_at
        )
      end
    end

    after do
      VCR.use_cassette('account/identity/token/after_successful_update') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_update_token' do
      VCR.use_cassette('account/identity/token/update_success') do
        response = @datasift.account_identity_token.update(
          identity_id: @identity_id,
          label: "#{@data.label}-update",
          status: 'active',
          master: false
        )
      end
      assert_equal STATUS.valid, response[:http][:status]
    end
  end

  describe 'unsuccessful :PUT' do
    it 'cannot_update_token_with_unknown_id' do
      VCR.use_cassette('account/identity/token/update_id_404') do
        response = @datasift.account_identity_token.update(
          identity_id: "fake_id",
          label: "#{@data.label}-update",
          status: 'active',
          master: false
        )
      end
      assert_equal STATUS.not_found, response[:http][:status]
    end

    it 'cannot_update_without_identity_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.update(
          label: "#{@data.label}-update",
          status: 'active',
          master: false
        )
      end
    end
  end

  ##
  # :DELETE /account/identity/token
  #
  describe ':DELETE' do
    before do
      VCR.use_cassette('account/identity/token/before_delete') do
        identity = @datasift.account_identity.create(label: @data.label)
        @identity_id = identity[:data][:id]
        response = @datasift.account_identity_token.create(
          identity_id: @identity_id,
          service: @data.service,
          token: @data.token,
          expires_at: @data.expires_at
        )
      end
    end

    after do
      VCR.use_cassette('account/identity/token/after_delete') do
        @datasift.account_identity.delete @identity_id
      end
    end

    it 'can_delete_identity' do
      VCR.use_cassette('account/identity/token/delete_success') do
        @datasift.account_identity_token.delete(
          identity_id: @identity_id,
          service: @data.service
        )
      end
    end

    it 'cannot_delete_without_id' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.delete(
          service: @data.service
        )
      end
    end

    it 'cannot_delete_without_service' do
      assert_raises ArgumentError do
        @datasift.account_identity_token.delete(
          identity_id: @identity_id
        )
      end
    end
  end
end
