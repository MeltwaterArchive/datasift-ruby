require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::HistoricsPreview' do
  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
    @statuses = OpenStruct.new
    @headers  = OpenStruct.new

    @statuses.valid = 200
    @statuses.accepted = 202

    @data.valid_csdl = 'interaction.content contains "ruby"'
    @data.sources = 'facebook,twitter'
    @data.parameters = 'language.tag,freqDist,5;interaction.id,targetVol,hour'
    @data.start = '1398898800'
    @data.end = '1398985200'
  end

  ##
  # /preview/create
  #
  describe '#create' do
    before do
      VCR.use_cassette('preview/before_preview_create') do
        @hash = @datasift.compile(@data.valid_csdl)[:data][:hash]
      end
    end

    it 'can_create_historics_preview' do
      VCR.use_cassette('preview/preview_create_success') do
        response = @datasift.historics_preview.create(@hash, @data.sources, @data.parameters, @data.start, @data.end)
        assert_equal @statuses.accepted, response[:http][:status]
      end
    end
  end

  ##
  # /preview/get
  #
  describe '#get' do
    before do
      VCR.use_cassette('preview/before_preview_get') do
        @hash = @datasift.compile(@data.valid_csdl)[:data][:hash]
        @preview = @datasift.historics_preview.create(@hash, @data.sources, @data.parameters, @data.start, @data.end)
      end
    end

    it 'can get an Historics Preview' do
      VCR.use_cassette('preview/preview_get_success') do
        response = @datasift.historics_preview.get(@preview[:data][:id])
        assert_equal @statuses.accepted, response[:http][:status]
      end
    end
  end
end
