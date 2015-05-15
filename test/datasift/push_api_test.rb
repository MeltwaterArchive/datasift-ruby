require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::Push' do

  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new

    @data.valid_csdl = 'interaction.content contains "test"'

    # Grab Push config from auth.rb
    @data.params = auth.params
  end

  ##
  # /push/validate
  #
  describe '#push/validate' do
    it 'can validate a push destination' do
      VCR.use_cassette('push/push_validate') do
        @datasift.push.valid? @data.params
        assert @datasift.push.valid?(@data.params), 'Valid config must return true'
      end
    end
  end

  ##
  # /push/create
  #
  describe '#push/create' do
    before do
      VCR.use_cassette('push/before_push_create') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    after do
      VCR.use_cassette('push/after_push_create') do
        @datasift.push.delete @response[:data][:id]
      end
    end

    it 'can create a push subscription' do
      VCR.use_cassette('push/push_create') do
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        @response = @datasift.push.create params
        assert_equal STATUS.valid, @response[:http][:status]
      end
    end
  end

  ##
  # /push/get
  #
  describe '#push/get' do
    before do
      VCR.use_cassette('push/before_push_get') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette('push/after_push_get') do
        @datasift.push.delete @id
      end
    end

    it 'can get a specific push subscription' do
      VCR.use_cassette('push/push_get_by_id') do
        response = @datasift.push.get_by_subscription @id
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/stop
  #
  describe '#push/stop' do
    before do
      VCR.use_cassette('push/before_push_stop') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette('push/after_push_stop') do
        @datasift.push.delete @id
      end
    end

    it 'can stop a push subscription' do
      VCR.use_cassette('push/push_stop') do
        response = @datasift.push.stop @id
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/log
  #
  describe '#push/log' do
    before do
      VCR.use_cassette('push/before_push_log') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette('push/after_push_log') do
        @datasift.push.delete @id
      end
    end

    it 'can get the /push/log for a given subscription' do
      VCR.use_cassette('push/push_log_with_id') do
        response = @datasift.push.log_for @id
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/pause
  #
  describe '#push/pause' do
    before do
      VCR.use_cassette('push/before_push_pause') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette('push/after_push_pause') do
        @datasift.push.delete @id
      end
    end

    it 'can pause a push subscription' do
      VCR.use_cassette('push/push_pause') do
        response = @datasift.push.pause @id
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/resume
  #
  describe '#push/resume' do
    before do
      VCR.use_cassette('push/before_push_resume') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
        @datasift.push.pause @id
      end
    end

    after do
      VCR.use_cassette('push/after_push_resume') do
        @datasift.push.delete @id
      end
    end

    it 'can resume a push subscription' do
      VCR.use_cassette('push/push_resume') do
        response = @datasift.push.resume @id
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/update
  #
  describe '#push/update' do
    before do
      VCR.use_cassette('push/before_push_update') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette('push/after_push_update') do
        @datasift.push.delete @id
      end
    end

    it 'can update a push subscription' do
      VCR.use_cassette('push/push_update') do
        @data.params[:id] = @id
        @data.params[:output_params][:directory] = 'new_directory'
        response = @datasift.push.update @data.params
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /push/delete
  #
  describe '#push/delete' do
    before do
      VCR.use_cassette('push/before_push_delete') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = @data.params.merge('hash' => @filter, 'name' => 'Ruby Push Example')
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    it 'can delete a push subscription' do
      VCR.use_cassette('push/push_delete') do
        response = @datasift.push.delete @id
        assert_equal STATUS.no_content, response[:http][:status]
      end
    end
  end
end
