require File.expand_path('../../../test_helper', __FILE__)

describe 'DataSift::Tasks' do

  before do
    @datasift = DataSiftExample.new.datasift
    @data = OpenStruct.new
    @data.subscription_id = 'cd99abbc812f646c77bfd8ddf767a134f0b91e84'
  end

  ##
  # /tasks/create
  #
  describe '#tasks/create' do
    it 'can create an analysis Task' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/task_create') do
        response = @datasift.task.create(
          service: 'linkedin',
          subscription_id: @data.subscription_id,
          name: 'Ruby Client FreqDist Task',
          type: 'analysis',
          parameters: {
            filter: "",
            start: (DateTime.now - 7).to_time.to_i,
            end: DateTime.now.to_time.to_i,
            parameters: {
              analysis_type: 'freqDist',
              parameters: {
                threshold: 5,
                target: 'li.user.member.metro_area',
              }
            }
          }
        )

        assert_equal STATUS.accepted, response[:http][:status]
      end
    end

    it 'can create a strategies Task' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/strategy_task_create') do
        response = @datasift.task.create(
          service: 'linkedin',
          subscription_id: @data.subscription_id,
          name: 'Ruby client test - top domains',
          type: 'strategy',
          parameters: {
            insight: 'top_domains',
            version: 1,
            parameters: {
              comparison_audience: 'global',
              audience: {
                industries: [
                  'internet'
                ]
              }
            }
          }
        )

        assert_equal STATUS.accepted, response[:http][:status]
      end
    end
  end

  ##
  # /tasks/get (By ID)
  #
  describe '#tasks/get' do
    before do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/before_get_by_id') do
        @task = @datasift.task.create(
          service: 'linkedin',
          subscription_id: @data.subscription_id,
          name: 'Ruby Client FreqDist Task',
          type: 'analysis',
          parameters: {
            filter: "",
            start: (DateTime.now - 7).to_time.to_i,
            end: DateTime.now.to_time.to_i,
            parameters: {
              analysis_type: 'freqDist',
              parameters: {
                threshold: 5,
                target: 'li.user.member.metro_area',
              }
            }
          }
        )
      end
    end

    it 'can get a specific Task by ID' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/task_get') do
        response = @datasift.task.get(service: 'linkedin', type: 'analysis', id: @task[:data][:id])

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

  ##
  # /tasks/get (list)
  #
  describe '#tasks/get (list)' do
    it 'can list analysis Tasks' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/task_list') do
        response = @datasift.task.list(service: 'linkedin', type: 'analysis')

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
    it 'can list analysis Tasks using pagination and filters' do
      VCR.use_cassette("#{@datasift.config[:api_version]}" + '/tasks/task_list_paged') do
        response = @datasift.task.list(service: 'linkedin', per_page: 5, page: 1, status: 'completed')

        assert_equal STATUS.valid, response[:http][:status]
      end
    end
  end

end
