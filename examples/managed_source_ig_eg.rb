require './auth'
class ManagedSourceApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    puts "Creating a managed source--\n"
    parameters = {
      likes: true,
      comments: true
    }
    resources = [{
      parameters: {
        type: 'user',
        value: 25025320
      }
    }]
    auth = [{
      parameters: {
        value: '10942122.00a3229.fff654d524854054bdb0288a05cdbdd1'
      }
    }]

    source = @datasift.managed_source.create(
      'instagram', 'Ruby test', parameters, resources, auth
    )
    puts source[:data].to_json

    id = source[:data][:id]

    puts "\nStarting delivery for my Managed Source--\n"
    puts @datasift.managed_source.start(id)[:data].to_json

    # Define new resources to be added
    update_resources = [{
      parameters: {
        type: 'user',
        value: 8139971
      }
    }]

    # Push each of the existing resources back into the new resources array
    source[:data][:resources].each do |resource|
      update_resources.push(resource)
    end

    puts "\nUpdating; adding a new resource, and changing the name--\n"
    puts @datasift.managed_source.update(
      id, 'instagram', 'Updated Ruby test', source[:data][:parameters],
      update_resources, source[:data][:auth]
    )[:data].to_json

    puts "\nGetting info from DataSift about my source--\n"
    puts @datasift.managed_source.get(id)[:data].to_json

    # Define new resources to add to Managed Source
    new_resources = [
      {
        parameters: {
          type: 'tag',
          value: 'sun'
        }
      },
      {
        parameters: {
          type: 'tag',
          value: 'sea'
        }
      },
      {
        parameters: {
          type: 'tag',
          value: 'surf'
        }
      }
    ]

    new_auth = [{
      parameters: {
        value: '10942111.1f2134f.8837abb205b44ece801022f6fa989cc4'
      }
    }]

    puts "\nAdding a new resource to my source (as array of Ruby objects)--\n"
    puts @datasift.managed_source_resource.add(
      id, new_resources
    )[:data].to_json

    puts "\nAdding a new token to my source (as array of Ruby objects)--\n"
    puts @datasift.managed_source_auth.add(id, new_auth)[:data].to_json

    puts "\nGetting info from DataSift about my source (notice the new " \
      "resources and tokens have been added)--\n"
    source = @datasift.managed_source.get id
    puts source[:data].to_json

    puts "\nRemoving a resource from my source by resource_id--\n"
    puts @datasift.managed_source_resource.remove(
      id, [source[:data][:resources][0][:resource_id]]
    )[:data].to_json

    puts "\nRemoving an auth token from my source by identity_id--\n"
    puts @datasift.managed_source_auth.remove(
      id, [source[:data][:auth][0][:identity_id]]
    )[:data].to_json

    puts "\nGetting info from DataSift about my source (notice an auth " \
      "token and resource have been removed)--\n"
    puts @datasift.managed_source.get(id)[:data].to_json

    puts "\nFetching logs--\n"
    puts @datasift.managed_source.log(id)[:data].to_json

    puts "\nStopping--\n"
    puts @datasift.managed_source.stop(id)[:data].to_json

    puts "\nDeleting--\n"
    puts @datasift.managed_source.delete(id)[:data].to_json
    rescue DataSiftError => dse
      puts dse.message
  end
end

ManagedSourceApi.new
