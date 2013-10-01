require './auth'
class PushApi < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      params = {
          :output_type                       => 's3',
          'output_params.bucket'             => 'apitests',
          'output_params.directory'          => 'ruby',
          'output_params.acl'                => 'private',
          'output_params.auth.access_key'    => 'AKIAIINK5C4FH75RSWNA',
          'output_params.auth.secret_key'    => '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',
          'output_params.delivery_frequency' => 0,
          'output_params.max_size'           => 10485760,
          'output_params.file_prefix'        => 'DataSift',
      }
      puts 'Validating'
      if @datasift.push.valid? params
        stream        = @datasift.compile 'interaction.content contains "datasift"'
        create_params = params.merge ({
            #hash or playback_id can be used but not both
            :hash           => stream[:data][:hash],
            :name           => 'My awesome push subscription',
            :initial_status => 'active', # or 'paused' or 'waiting_for_start'
            :start          => Time.now.to_i,
            :end            => Time.now.to_i + 320
        })
        puts 'Creating subscription'
        subscription = @datasift.push.create create_params
        puts 'Create push => ' + subscription.to_s

        subscription_id = subscription[:data][:id]
        #pull a bunch of interactions from the push queue - only work if we had set the output_type above to pull
        #pull @datasift.pull subscription_id

        puts 'updating subscription'
        # update the info we just used to create
        # id, name and output_params.* are valid
        puts @datasift.push.update params.merge({:id => subscription_id, :name => 'My updated awesome name'})

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
PushApi.new