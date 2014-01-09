require './auth'
class PushApi < DataSiftExample
  def initialize
    super
  end

  def run(count)
    begin
      subscription = create_push('5cdb0c8b4f3f6ca26f6ba1b086f22edd', count)

      subscription_id = subscription[:data][:id]
      #pull a bunch of interactions from the push queue - only work if we had set the output_type above to pull
      #pull @datasift.pull subscription_id

      puts 'getting subscription info'
      # get details for a subscription also available are
      # push.[get, get_by_hash,get_by_historics_id]
      puts @datasift.push.get_by_subscription subscription_id
    rescue DataSiftError => dse
      puts dse.message
    end
  end

  def get_all
    puts MultiJson.dump(@datasift.push.get(1, 500))
  end
end

p = PushApi.new()
#for i in 1..1000
#  p.run(i)
#end
p.get_all()