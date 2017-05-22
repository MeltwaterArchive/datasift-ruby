require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::ManagedSourceResource' do
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
  # /source/resource/add
  #
  describe '#source/resource/add' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/before_add') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/after_add') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can add a resource to an existing Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/add') do
        new_resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource_2 } }]
        response = @datasift.managed_source_resource.add(@source[:data][:id], new_resource, false)

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /source/resource/remove
  #
  describe '#source/resource/remove' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/before_remove') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }, { parameters: { type: 'tag', value: @data.instagram.tag_resource_2 } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/after_remove') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can remove a resource from an existing Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/resource/remove') do
        response = @datasift.managed_source_resource.remove(@source[:data][:id], [@source[:data][:resources][0][:resource_id]])

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end
end
