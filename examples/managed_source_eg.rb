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
                    :comments        => true,
                    :page_likes      => true
      }
      resources  = [{
                        :parameters => {
                            :url   => 'http://www.facebook.com/theguardian',
                            :title => 'Some news page',
                            :id    => :theguardian
                        }
                    }]
      auth       = [{
                        :parameters => {
                            :value => 'CAAIUKbXn8xsBAN5MnINICUT9gEBsZBh3hKoSEeIMP0ZA4zadMr64X6ljvZC4VBZCyYr9tyhih5nO0R39A1FQ848v0mZA6d3ehIHuSbKb7avtfLOtL5XKDYRIXHmRWreyxxVc3jk7CIa4ZCI5AAKeUUO3GUS8EaPdYVh9rO5FvvNmIatzz6k8el'
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