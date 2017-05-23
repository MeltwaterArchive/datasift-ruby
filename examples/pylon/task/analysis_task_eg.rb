##
# This script runs through all PYLON Tasks API endpoints
##
require './../../auth'
class TaskApi < DataSiftExample
  def initialize
    super
    run_tasks
  end

  def run_tasks
    begin
      # Make Tasks API calls using an Identity API key
      @datasift = DataSift::Client.new(
        username: @config[:username],
        api_key: @config[:identity_api_key],
        api_version: @config[:api_version]
      )

      puts "Creating a new analysis Task by adding it to our processing queue"
      analysis_task = @datasift.task.create(
        service: 'linkedin',
        subscription_id: 'cd99abbc812f646c77bfd8ddf767a134f0b91e84',
        name: 'Ruby Client FreqDist Task',
        type: 'analysis',
        parameters: {
          filter: "",
          start: (DateTime.now - 7).to_time.to_i,
          end: DateTime.now.to_time.to_i,
          parameters: {
            analysis_type: 'freqDist',
            parameters: {
              threshold: 3,
              target: 'li.user.member.metro_area',
            }
          }
        }
      )
      puts analysis_task[:data].to_json

      puts "\nYou can list your Tasks, filtering by type, status and page\n" +
      "Here we'll pull the first page of our completed analysis tasks"
      puts @datasift.task.list(service: 'linkedin', type: 'analysis', status: 'completed', page: 1)[:data]

      puts "\nGet results of our new analysis Task by ID"
      begin
         get_task = @datasift.task.get(service: 'linkedin', type: 'analysis', id: analysis_task[:data][:id])
         sleep 2
         puts '...Waiting for Task to complete...'
      end until get_task[:data][:status] == 'completed'
      puts get_task[:data].to_json

      rescue DataSiftError => dse
        puts dse.inspect
    end
  end
end

TaskApi.new
