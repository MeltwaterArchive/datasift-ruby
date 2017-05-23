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
          'daily',
          1490054400,
          1490572800
        )
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'handles 400 when using invalid params' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/account/usage/invalid') do
        assert_raises BadRequestError do
          @datasift.account.usage('invalid_period')
        end
      end
    end
  end
end
