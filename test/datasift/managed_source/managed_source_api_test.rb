require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::ManagedSource' do
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
  # /source/create
  #
  describe '#source/create (success)' do
    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_create') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can create a new Instagram Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_create') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})

        assert_equal STATUS.created, @source[:http][:status]
      end
    end
  end

  ##
  # /source/get (by ID)
  #
  describe '#source/get (success)' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_get') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_get') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can get an existing Managed Source by ID' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_get') do
        response = @datasift.managed_source.get(@source[:data][:id])
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /source/get (list)
  #
  describe '#source/get (list success)' do
    it 'can list existing Managed Sources' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_list') do
        assert_equal STATUS.valid, @datasift.managed_source.get[:http][:status]
      end
    end
  end

  ##
  # /source/update
  #
  describe '#source/update (success)' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_update') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_update') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can update an existing source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_update') do
        new_name = "New Name"
        response = @datasift.managed_source.update(
          @source[:data][:id],
          @source[:data][:source_type],
          new_name,
          @source[:data][:parameters],
          @source[:data][:resources],
          @source[:data][:auth]
        )

        assert_equal STATUS.accepted, response[:http][:status]
        assert_equal new_name, response[:data][:name]
      end
    end

  end

  ##
  # /source/start
  #
  describe '#source/start (success)' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_start') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_start') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can start a source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_start') do
        response = @datasift.managed_source.start(@source[:data][:id])

        assert_equal STATUS.valid, response[:http][:status]
        assert_equal 'running', @datasift.managed_source.get(@source[:data][:id])[:data][:status]
      end
    end
  end

  ##
  # /source/stop
  #
  describe '#source/stop (success)' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_stop') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
        @datasift.managed_source.start(@source[:data][:id])
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_stop') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can stop a source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_stop') do
        response = @datasift.managed_source.stop(@source[:data][:id])

        assert_equal STATUS.valid, response[:http][:status]
        assert_equal 'stopped', @datasift.managed_source.get(@source[:data][:id])[:data][:status]
      end
    end
  end

  ##
  # /source/log
  #
  describe '#source/log (success)' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_log') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_log') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can get logs for a specific Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_log') do
        response = @datasift.managed_source.log(@source[:data][:id])

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /source/delete
  #
  describe '#source/delete' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/before_source_delete') do
        params = {comments: false, likes: false}
        auth = [{ parameters: { value: @data.instagram.token } }]
        resource = [{ parameters: { type: 'tag', value: @data.instagram.tag_resource } }]
        @source = @datasift.managed_source.create('instagram', 'Ruby Test IG', params, resource, auth, {validate: false})
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/after_source_delete') do
        begin
          @datasift.managed_source.delete @source[:data][:id]
        rescue ApiResourceNotFoundError
        end
      end
    end

    it 'can delete a Managed Source' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/source/source_delete') do
        response = @datasift.managed_source.delete(@source[:data][:id])

        assert_equal STATUS.no_content, response[:http][:status]
        assert_raises ApiResourceNotFoundError do
          @datasift.managed_source.get(@source[:data][:id])
        end
      end
    end
  end
end
