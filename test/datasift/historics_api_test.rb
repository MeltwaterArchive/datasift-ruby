require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::Historics' do

  before do
    @datasift = DataSiftExample.new.datasift

    @data = OpenStruct.new
    @data.valid_csdl = 'interaction.content contains "test"'
    @data.params = DataSiftExample.new.pull_params
    @data.start_time = 1477958400
    @data.end_time = 1478044800
  end

  ##
  # /historics/prepare
  #
  describe '#historics/prepare' do
    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_prepare') do
        @datasift.historics.delete @historics_id
      end
    end

    it 'can prepare an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_prepare') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        response = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )
        @historics_id = response[:data][:id]

        assert_equal STATUS.accepted, response[:http][:status]
      end
    end
  end

  ##
  # /historics/get (by ID)
  #
  describe '#historics/get by id' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_get_by_id') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_get_by_id') do
        @datasift.historics.delete @historics_id
      end
    end

    it 'can get an Historics query by ID' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_get_by_id') do
        response = @datasift.historics.get_by_id @historics_id

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /historics/get (list)
  #
  describe '#historics/get list' do
    it 'can list Historics queries' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_get_list') do
        response = @datasift.historics.get

        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can list Historics queries with pagination' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_get_list') do
        response = @datasift.historics.get(1, 1)

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end



  ##
  # /historics/start
  #
  describe '#historics/start' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_start') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
        @data.params[:historics_id] = @historics_id
        @data.params[:name] = 'Historics Push Subscription'
        @push_id = @datasift.push.create(@data.params)[:data][:id]
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_start') do
        @datasift.historics.delete @historics_id
        @datasift.push.delete @push_id
      end
    end

    it 'can start an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_start') do
        response = @datasift.historics.start @historics_id

        assert_equal STATUS.no_content, response[:http][:status]
      end
    end
  end

  ##
  # /historics/stop
  #
  describe '#historics/stop' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_stop') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
        @data.params[:historics_id] = @historics_id
        @data.params[:name] = 'Historics Push Subscription'
        @push_id = @datasift.push.create(@data.params)[:data][:id]
        @datasift.historics.start @historics_id
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_stop') do
        @datasift.historics.delete @historics_id
        @datasift.push.delete @push_id
      end
    end

    it 'can stop an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_stop') do
        response = @datasift.historics.stop @historics_id

        assert_equal STATUS.no_content, response[:http][:status]
      end
    end
  end

  ##
  # /historics/pause
  #
  describe '#historics/pause' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_pause') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
        @data.params[:historics_id] = @historics_id
        @data.params[:name] = 'Historics Push Subscription'
        @push_id = @datasift.push.create(@data.params)[:data][:id]
        @datasift.historics.start @historics_id
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_pause') do
        @datasift.historics.delete @historics_id
        @datasift.push.delete @push_id
      end
    end

    it 'can pause an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_pause') do
        response = @datasift.historics.pause @historics_id

        assert_equal STATUS.no_content, response[:http][:status]
      end
    end
  end

  ##
  # /historics/resume
  #
  describe '#historics/resume' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_resume') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
        @data.params[:historics_id] = @historics_id
        @data.params[:name] = 'Historics Push Subscription'
        @push_id = @datasift.push.create(@data.params)[:data][:id]
        @datasift.historics.start @historics_id
        @datasift.historics.pause @historics_id
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_resume') do
        @datasift.historics.delete @historics_id
        @datasift.push.delete @push_id
      end
    end

    it 'can resume an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_resume') do
        response = @datasift.historics.resume @historics_id

        assert_equal STATUS.no_content, response[:http][:status]
      end
    end
  end

  ##
  # /historics/update
  #
  describe '#historics/update' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_update') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_update') do
        @datasift.historics.delete @historics_id
      end
    end

    it 'can update an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_update') do
        new_name = 'New Historics query name'
        response = @datasift.historics.update(@historics_id, new_name)

        assert_equal STATUS.no_content, response[:http][:status]
        assert_equal new_name, @datasift.historics.get_by_id(@historics_id)[:data][:name]
      end
    end
  end

  ##
  # /historics/delete
  #
  describe '#historics/delete' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/before_historics_delete') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @historics_id = @datasift.historics.prepare(
          @filter,
          @data.start_time,
          @data.end_time,
          'Historics name',
          'tumblr'
        )[:data][:id]
        @data.params[:historics_id] = @historics_id
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/after_historics_delete') do
        begin
          @datasift.historics.delete @historics_id
        rescue ApiResourceNotFoundError
        end
      end
    end

    it 'can delete an Historics query' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/historics/historics_delete') do
        response = @datasift.historics.delete @historics_id

        assert_equal STATUS.no_content, response[:http][:status]
        assert_raises ApiResourceNotFoundError do
          @datasift.historics.get_by_id @historics_id
        end
      end
    end
  end
end
