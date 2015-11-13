require './auth'
class PushApi < DataSiftExample
  def initialize
    super
  end

  def run
    begin
      @params = {output_type: 'pull'}
      puts 'Validating the Pull subscription'
      fail InvalidParamError unless @datasift.push.valid? @params

      stream = @datasift.compile 'interaction.content contains "music"'
      subscription = create_push(stream[:data][:hash])

      subscription_id = subscription[:data][:id]
      # Pull a bunch of interactions from the push queue. This only works if we had set the
      #   output_type above to "pull"

      2.times do
        puts "\nPulling data, then waiting 10 seconds"
        @datasift.push.pull(subscription_id).each { |e| puts e }
        sleep 10
      end

      puts "\nPulling data the third and final time time"
      # Passing a lambda is more efficient because it is executed once for each interaction
      #   received this saves having to iterate over the array returned so the same iteration
      #   isn't processed twice
      @datasift.push.pull(
        subscription_id,
        20_971_520,
        '',
        lambda{ |e| puts "on_message => #{e}" }
      )

      puts "\nDeleting the Pull subscription"
      @datasift.push.delete subscription_id

        #rescue DataSiftError
    rescue DataSiftError => dse
      puts dse.inspect
    end
  end
end

PushApi.new().run
