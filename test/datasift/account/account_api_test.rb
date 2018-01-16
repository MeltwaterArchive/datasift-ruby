require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::Account' do
  before do
    @datasift = DataSiftExample.new.datasift
  end

  ##
  # Account Usage
  #
  describe '#usage' do
    it 'can get account usage using valid params' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/account/usage/valid_params') do
        response = @datasift.account.usage(
          1490054400,
          1490572800,
          'daily'
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'raises argument error when using invalid params' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/account/usage/invalid') do
        assert_raises ArgumentError do
          @datasift.account.usage()
        end
      end
    end

    it 'handles 400 when using invalid params' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/account/usage/invalid') do
        assert_raises BadRequestError do
          @datasift.account.usage(
          1490054400,
          1490572800,
          'invalid_period'
        )
        end
      end
    end
  end
end
