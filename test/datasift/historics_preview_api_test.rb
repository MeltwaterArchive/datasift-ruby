require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::HistoricsPreview' do

  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
    @statuses = OpenStruct.new
    @headers  = OpenStruct.new

    @statuses.valid     = 200
    @statuses.accepted  = 202
  end

  describe '#create' do
    before do
      @data.stream_hash = '145ea24a4d83a14ecb9077b831f14809'
      @data.sources     = 'facebook,twitter'
      @data.parameters  = 'language.tag,freqDist,5;interaction.id,targetVol,hour'
      @data.start       = '1398898800'
      @data.end         = '1398985200'

      @headers.preview_create = {
            "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
            "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
            "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "25"}

      #valid /preview/create request
      stub_request(:post, /api.datasift.com\/.*\/preview\/create/).
          with(:body => { :hash       => @data.stream_hash,
                          :sources    => @data.sources,
                          :parameters => @data.parameters,
                          :start      => @data.start,
                          :end        => @data.end}).
          to_return(status:  @statuses.valid,
                    body:    fixture('preview_create_valid.json'),
                    headers: @headers.preview_create)
    end

    it 'can create an Historics Preview' do
      @datasift.historics_preview.create(@data.stream_hash, @data.sources, @data.parameters, @data.start, @data.end)
      assert_requested( :post,
                        'https://api.datasift.com/v1/preview/create',
                        :body => {:start      => @data.start,
                                  :end        => @data.end,
                                  :hash       => @data.stream_hash,
                                  :sources    => @data.sources,
                                  :parameters => @data.parameters})
    end

  end

  describe '#get' do
    before do
      @data.id = 'fbd5441ab17a46f2ac200f8cab6bdb79fe8efb31'

      @headers.preview_get = {
            "date"              => "Thu, 30 Jan 2014 10:09:19 GMT", "content-type" => "application/json",
            "transfer-encoding" => "chunked", "connection" => "close", "x-api-version" => "1",
            "x-ratelimit-limit" => "10000", "x-ratelimit-remaining" => "10000", "x-ratelimit-cost" => "5"}

      #valid /preview/get running request
      stub_request(:post, /api.datasift.com\/.*\/preview\/get/).
          with(:body => { :id => @data.id}).
          to_return(status:  @statuses.accepted,
                    body:    fixture('preview_get_running.json'),
                    headers: @headers.preview_get)

      #valid /preview/get succeeded request
      stub_request(:post, /api.datasift.com\/.*\/preview\/get/).
          with(:body => { :id => @data.id}).
          to_return(status:  @statuses.valid,
                    body:    fixture('preview_get_succeeded.json'),
                    headers: @headers.preview_get)
    end

    it 'can get an Historics Preview' do
      @datasift.historics_preview.get(@data.id)
      assert_requested( :post, 'https://api.datasift.com/v1/preview/get', :body => {:id => @data.id})
    end
  end
end
