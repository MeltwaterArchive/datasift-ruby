require './auth'
class ManagedSourceApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin
      puts 'Creating a managed source'
      parameters = {:likes           => true,
                    :posts_by_others => true,
                    :comments        => true
      }
      resources  = [{
                        :parameters => {
                            :url   => 'http://www.facebook.com/thegaurdian',
                            :title => 'Some news page',
                            :id    => :thegaurdian
                        }
                    }]
      auth       = [{
                        :parameters => {
                            :value => 'CAAIUKbXn8xsBAFETaaoZCYCFdXe15dS0SzACfQ4aV66GZBcL4Bs6I5w3jEgPlbWQxragMkgBad9UhSTfsQFwMBdQmU65UGQkuUI2ADncL7puFKdTiFLb7fUoboTTeCJAAUQ3ltuTRjZAf4P83IUsFqI6jbbXFUCw03jcVROR8PZABRXzUFiM6'
                        }
                    }]

      source = @datasift.managed_source.create('facebook_page', 'My managed source', parameters, resources, auth)
      puts source

      id = source[:data][:id]

      puts 'Starting delivery for my private source'
      puts @datasift.managed_source.start id

      puts 'Updating'
      puts @datasift.managed_source.update(id, 'facebook_page', 'Updated source', parameters, resources, auth)

      puts 'Getting info from DataSift about my page'
      puts @datasift.managed_source.get id

      puts 'Fetching logs'
      puts @datasift.managed_source.log id

      puts 'Stopping'
      puts @datasift.managed_source.stop id

      puts 'Deleting'
      puts @datasift.managed_source.delete id
    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

ManagedSourceApi.new