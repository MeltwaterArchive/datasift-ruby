require './auth'
class PushApi < DataSiftExample
  def initialize
    super
  end

  def run
    begin
      @params = {:output_type => 'pull'}
      puts 'Validating'
      if @datasift.push.valid? @params
        stream = @datasift.compile 'interaction.content contains "music"'
        subscription = create_push(stream[:data][:hash])

        subscription_id = subscription[:data][:id]
        #pull a bunch of interactions from the push queue - only work if we had set the output_type above to pull
        #pull @datasift.pull subscription_id

        puts 'pullinga'
        @datasift.push.pull(subscription_id).each { |e| puts e }

        sleep 10

        puts 'pullingb'
        @datasift.push.pull(subscription_id).each { |e| puts e }

        sleep 10

        puts 'pullingc'
        @datasift.push.pull(subscription_id).each { |e| puts e }

        puts 'pullingdelete'
        @datasift.push.delete subscription_id
      end
        #rescue DataSiftError
    rescue DataSiftError => dse
      puts dse.inspect
    end
  end

end
PushApi.new().run