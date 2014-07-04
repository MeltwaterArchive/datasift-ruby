require './auth'
class PushApi < DataSiftExample
  def initialize
    super
  end

  def run
    begin
      @params = {:output_type => 'pull'}
      puts 'Validating the Pull subscription'
      if @datasift.push.valid? @params
        stream = @datasift.compile 'interaction.content contains "music"'
        subscription = create_push(stream[:data][:hash])

        subscription_id = subscription[:data][:id]
        #pull a bunch of interactions from the push queue - only work if we had set the output_type above to pull
        #pull @datasift.pull subscription_id

        puts "\nPulling data a first time, then waiting 10 seconds"
        @datasift.push.pull(subscription_id).each { |e| puts e }

        sleep 10

        puts "\nPulling data a second time, then waiting 10 seconds"
        @datasift.push.pull(subscription_id).each { |e| puts e }

        sleep 10

        puts "\nPulling data the third and final time time"
        #passing a lambda is more efficient because it is executed once for each interaction received
        #this saves having to iterate over the array returned so the same iteration isn't done twice
        @datasift.push.pull(subscription_id, 20971520, '', lambda{ |e| puts "on_message => #{e}" })

        puts "\nDeleting the Pull subscription"
        @datasift.push.delete subscription_id
      end
        #rescue DataSiftError
    rescue DataSiftError => dse
      puts dse.inspect
    end
  end
end

PushApi.new().run
