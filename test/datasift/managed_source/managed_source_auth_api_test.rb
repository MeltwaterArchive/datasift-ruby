require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::ManagedSourceAuth' do
  before do
    @datasift = DataSiftExample.new.datasift

    @data = OpenStruct.new
    @data.instagram = OpenStruct.new
    @data.instagram.token = '458583326.0092129.a61ea13a945524651bacfd31f943a4ab'
    @data.instagram.token_2 = '458336276.0022012.a61a333a94524465b6acfd93f94340ab'
    @data.instagram.tag_resource = 'nofilter'
    @data.instagram.tag_resource_2 = 'instagram'
  end

  ##
  # /source/auth/add
  #
  describe '#source/auth/add' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/before_add') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/after_add') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can add an auth token to a Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/add') do
        new_auth = [{ parameters: { value: @data.instagram.token_2 } }]
        response = @datasift.managed_source_auth.add(@source[:data][:id], new_auth, false)

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /source/auth/remove
  #
  describe '#source/auth/remove' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/before_remove') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }, { parameters: { value: @data.instagram.token_2 } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/after_remove') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can remove an auth token from a Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/auth/remove') do
        response = @datasift.managed_source_auth.remove(@source[:data][:id], [@source[:data][:auth][0][:identity_id]])

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end
end
