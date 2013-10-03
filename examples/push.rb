require './auth'
class PushApi < DataSiftExample
  def initialize
    super
  end

  def run
    begin
      puts 'Validating'
      if @datasift.push.valid? @params
        stream       = @datasift.compile 'interaction.content contains "datasift"'
        subscription = create_push(stream[:data][:hash])

        subscription_id = subscription[:data][:id]
        #pull a bunch of interactions from the push queue - only work if we had set the output_type above to pull
        #pull @datasift.pull subscription_id

        puts 'updating subscription'
        # update the info we just used to create
        # id, name and output_params.* are valid
        puts @datasift.push.update @params.merge({:id => subscription_id, :name => 'My updated awesome name'})

        puts 'getting subscription info'
        # get details for a subscription also available are
        # push.[get, get_by_hash,get_by_historics_id]
        puts @datasift.push.get_by_subscription subscription_id

        puts 'getting logs for subscription'
        # get log messages for a subscription id
        #also available push.logs to fetch logs for all subscriptions
        puts @datasift.push.logs_for subscription_id

        puts 'pausing subscription'
        #pause the subscription that was created
        puts @datasift.push.pause subscription_id

        puts 'resuming subscription'
        # resume the subscription that was just paused
        puts @datasift.push.resume subscription_id

        puts 'stopping subscription'
        # stop the subscription
        puts @datasift.push.stop subscription_id

        puts 'deleting subscription'
        #and delete it
        puts @datasift.push.delete subscription_id
      end
        #rescue DataSiftError
    rescue DataSiftError => dse
      puts dse.message
    end
  end

end
PushApi.new().run