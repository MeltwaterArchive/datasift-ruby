require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::Pull' do

  before do
    @datasift = DataSiftExample.new.datasift

    @data = OpenStruct.new
    @data.valid_csdl = 'interaction.content contains "test"'
  end

  ##
  # /pull
  #
  describe '#pull' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pull/before_pull') do
        @filter = @datasift.compile(@data.valid_csdl)[:data][:hash]
        params = {
          output_type: 'pull',
          hash: @filter,
          name: 'Ruby Pull Example'
        }
        response = @datasift.push.create params
        @id = response[:data][:id]
      end
    end

    after do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pull/after_pull') do
        @datasift.push.delete @id
      end
    end

    it 'can pull data from a Pull subscription' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/pull/pull') do
        response = @datasift.push.pull @id

        # This is a little naughty; if we've matched interactions during the test, we should
        #   receive a 200 response, else a 204. Both are acceptable
        if response[:data].empty?
          assert_equal STATUS.no_content, response[:http][:status]
        else
          assert_equal STATUS.valid, response[:http][:status]
        end
      end
    end
  end
end
