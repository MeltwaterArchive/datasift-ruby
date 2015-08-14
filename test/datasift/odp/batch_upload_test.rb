require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::Odp' do
  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
  end

  ##
  # Batch Upload
  #
  describe '#ingest (success)' do
    before do
      VCR.use_cassette('odp/batch/before_upload') do
        resource = [{ parameters: { mapping: "gnip_1" } }]
        @source = @datasift.managed_source.create('twitter_gnip', 'Ruby ODP API', {}, resource)
      end
    end

    after do
      VCR.use_cassette('odp/batch/after/upload') do
        @datasift.managed_source.delete @source[:data][:id]
      end
    end

    it 'can batch upload gnip twitter data' do
      VCR.use_cassette('odp/batch/upload_success') do
        payload = File.open(File.expand_path(__FILE__, "./../../fixtures/data/fake_gnip_tweets.json", "rb").read
        response = @datasift.odp.ingest(@source[:data][:id], payload)
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  describe '#ingest (failure)' do
    it 'handles 404 when Managed Source can not be found' do
      VCR.use_cassette('odp/batch/upload_failure_no_source') do
        payload = File.open(File.expand_path(__FILE__, "./../../fixtures/data/fake_gnip_tweets.json", "rb").read
        assert_raises ApiResourceNotFoundError do
          response = @datasift.odp.ingest('invalid_source_id', payload)
        end
      end
    end

    it 'raises BadParametersError when payload is missing' do
      assert_raises ArgumentError do
        @datasift.odp.ingest('invalid_source_id')
      end
    end
  end
end
