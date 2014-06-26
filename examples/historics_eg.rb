require './auth'
class HistoricsApi < DataSiftExample
  def initialize
    super
    run_historics
  end

  def run_historics
    begin
      stream   = @datasift.compile 'interaction.content contains "datasift"'
      hash     = stream[:data][:hash]
      start    = Time.now.to_i - 10800
      end_time = start + 3600

      puts 'Check the data coverage for this Historic period'
      puts @datasift.historics.status(start, end_time)

      puts 'Preparing'
      #prepare a historics to start from three hours ago and run for 1 hour using twitter as a data source and using only a 10% sample
      historics = @datasift.historics.prepare(hash, start, end_time, 'My ruby historics', 'twitter', 10)
      puts historics

      id = historics[:data][:id]

      puts 'Creating push subscription for historics'
      puts create_push(id, true)

      puts "Starting historics #{id}"
      puts @datasift.historics.start id

      puts "Pausing historics #{id}"
      puts @datasift.historics.pause id

      puts "Resuming historics #{id}"
      puts @datasift.historics.resume id

      puts 'Updating historics'
      puts @datasift.historics.update(id, 'The new name of my historics')

      puts 'Get info for the historics'
      puts @datasift.historics.get_by_id id

      puts 'Getting info for all my historics'
      puts @datasift.historics.get

      puts 'Stopping historics'
      puts @datasift.historics.stop id

      puts 'Deleting historics'
      puts @datasift.historics.delete id
    rescue DataSiftError => dse
      puts dse.message
    end
  end
end
HistoricsApi.new