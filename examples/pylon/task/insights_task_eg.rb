##
# This script runs through all PYLON Media Strategies API endpoints
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

      puts "Creating a new Task by adding it to our processing queue"
      task = @datasift.task.create(
        service: 'linkedin',
        subscription_id: 'cd99abbc812f646c77bfd8ddf767a134f0b91e84',
        name: 'Ruby Client Top URLs Task',
        type: 'strategy',
        parameters: {
          strategy: 'top_urls',
          version: 1,
          parameters: {
            audience: {
              sectors: [
                "legal",
                "finance"
              ]
            },
            comparison_audience: 'global',
            groups: {
              top: {
                "countries": 3
              }
            }
          },
        }
      )

      puts task[:data].to_json
      puts "\nYou can access the response[:datasift] attribute to see how much space you have\n" +
      "remaining in your task queue, and inspect other rate limits"
      puts task[:datasift].to_json

      puts "\nYou can list your Tasks, filtering by status or page\n" +
      "Here we'll pull the first page of our completed strategy tasks"
      puts @datasift.task.list(service: 'linkedin', type: 'strategy', status: 'completed', page: 1)[:data]

      puts "\nGet results of our new running Task by ID"
      begin
         get_task = @datasift.task.get(service: 'linkedin', type: 'strategy', id: task[:data][:id])
         sleep 2
         puts '...Waiting for Task to complete...'
         puts "Task progress: #{get_task[:data][:steps_completed]} of #{get_task[:data][:total_steps]} steps completed"
      end until get_task[:data][:status] == 'completed'
      puts get_task[:data].to_json

      rescue DataSiftError => dse
        puts dse.inspect
    end
  end
end

TaskApi.new
