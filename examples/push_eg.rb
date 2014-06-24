require './auth'
class PushApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin
      puts 'Creating Push subscription'
      subscription = @datasift.push.create @params.merge(hash: '54dbfc8464258de162b7f1a057e630c5', name: 'Ruby Client Example')

      subscription_id = subscription[:data][:id]
      puts "Push subscription created! Push Subscription ID #{subscription_id}"

      puts 'Getting subscription info'
      # Get details for a subscription. Also available are
      # push.[get, get_by_hash,get_by_historics_id]
      puts @datasift.push.get_by_subscription subscription_id

      puts 'Pausing Push subscription'
      # Push subscriptions can be paused for up to an hour
      @datasift.push.pause subscription_id

      puts 'Resuming Push subscription'
      # Push subscriptions must be resumed to continue delivering data
      @datasift.push.resume subscription_id

      puts 'Getting subscription logs'
      # Get logs for a subscription. Also available is
      # push.log to get logs for all subscriptions
      puts @datasift.push.log_for subscription_id

      puts 'Stopping Push subscription'
      # Push subscriptions can be stopped. Once stopped, a
      # subscription can not be resumed
      @datasift.push.stop subscription_id

      puts 'Deleting Push subscription'
      # Push subscriptions can be deleted. On delete, any undelivered
      # data is dropped. A delete is permenent.
      @datasift.push.delete subscription_id

    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

PushApi.new()
