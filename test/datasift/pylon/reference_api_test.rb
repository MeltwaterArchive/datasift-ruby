require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::Pylon.Reference' do

  before do
    @datasift = DataSiftExample.new.datasift
    @data = OpenStruct.new
  end

  ##
  # /pylon/{service}/reference (list)
  #
  describe '#pylon/linkedin/reference' do
    it 'can list reference data sets for Linkedin' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pylon/linkedin/reference') do
        response = @datasift.pylon.reference(service: 'linkedin')

        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can list reference data sets for Linkedin using pagination' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pylon/linkedin/reference') do
        per_page = 3
        response = @datasift.pylon.reference(service: 'linkedin', page: 1, per_page: per_page)

        assert_equal per_page, response[:data][:data].count
        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /pylon/{service}/reference/slug
  #
  describe '#pylon/linkedin/reference/' do
    it 'can list reference data sets for Linkedin' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pylon/linkedin/reference') do
        response = @datasift.pylon.reference(service: 'linkedin', slug: 'seniorities')

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end
end
