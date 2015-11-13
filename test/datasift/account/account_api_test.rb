require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::Account' do
  before do
    auth = DataSiftExample.new
    @datasift = auth.datasift
  end

  ##
  # Account Usage
  #
  describe '#usage' do
    it 'can get account usage using default params' do
      VCR.use_cassette('account/usage/default') do
        response = @datasift.account.usage
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'can get account usage using valid params' do
      VCR.use_cassette('account/usage/valid_params') do
        response = @datasift.account.usage('monthly')
        assert_equal STATUS.valid, response[:http][:status]
      end
    end

    it 'handles 400 when using invalid params' do
      VCR.use_cassette('account/usage/invalid') do
        assert_raises BadRequestError do
          @datasift.account.usage('invalid_period')
        end
      end
    end
  end
end
