require './auth'
class ManagedSourceApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    begin
      puts 'Creating a managed source'
      parameters = {
        :likes    => true,
        :comments => true
      }
      resources = [{
        :parameters => {
          :type   => 'user',
          :value  => 25025320
        }
      }]
      auth = [{
        :parameters => {
          :value => '10942122.00a3229.fff654d524854054bdb0288a05cdbdd1'
        }
      }]

      source = @datasift.managed_source.create('instagram', 'Ruby test', parameters, resources, auth)
      puts source

      id = source[:data][:id]

      puts "\nStarting delivery for my Managed Source"
      puts @datasift.managed_source.start id

      # Define new resources to be added
      update_resources = [{
        :parameters => {
          :type   => 'user',
          :value  => 8139971
        }
      }]

      # Push each of the existing resources back into the new resources array
      source[:data][:resources].each do |resource|
        update_resources.push(resource)
      end

      puts "\nUpdating; adding a new resource, and changing the name"
      puts @datasift.managed_source.update(id, 'instagram', 'Updated Ruby test', source[:data][:parameters], update_resources, source[:data][:auth])

      puts "\nGetting info from DataSift about my source"
      puts @datasift.managed_source.get id

      # Define new resources to add to Managed Source
      new_resources = [{
        :parameters => {
          :type   => "tag",
          :value  => "sun"
        }
      },
      {
        :parameters => {
          :type   => "tag",
          :value  => "sea"
        }
      },
      {
        :parameters => {
          :type   => "tag",
          :value  => "surf"
        }
      }]

      new_auth = [{
        :parameters => {
          :value => '10942111.1f2134f.8837abb205b44ece801022f6fa989cc4'
        }
      }]

      puts "\nAdding a new resource to my source (as an array of Ruby objects)"
      puts @datasift.managed_source_resource.add(id, new_resources)

      puts "\nAdding a new auth token to my source (as an array of Ruby objects)"
      puts @datasift.managed_source_auth.add(id, new_auth)

      puts "\nGetting info from DataSift about my source (notice the new resources and tokens have been added)"
      source = @datasift.managed_source.get id
      puts source

      puts "\nRemoving a resource from my source by resource_id"
      puts @datasift.managed_source_resource.remove(id, [source[:data][:resources][0][:resource_id]])

      puts "\nRemoving an auth token from my source by identity_id"
      puts @datasift.managed_source_auth.remove(id, [source[:data][:auth][0][:identity_id]])

      puts "\nGetting info from DataSift about my source (notice an auth token and resource have been removed)"
      puts @datasift.managed_source.get id

      puts "\nFetching logs"
      puts @datasift.managed_source.log id

      puts "\nStopping"
      puts @datasift.managed_source.stop id

      puts "\nDeleting"
      puts @datasift.managed_source.delete id
    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

ManagedSourceApi.new
