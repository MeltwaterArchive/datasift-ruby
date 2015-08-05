require './auth'
class ManagedSourceApi < DataSiftExample
  def initialize
    super
    run
  end

  def run
    puts "Creating a managed source\n--"
    parameters = {
      likes: true,
      posts_by_others: true,
      comments: true,
      page_likes: true
    }
    resources = [{
      parameters: {
        id: 130871750291428,
        title: 'DataSift'
      }
    }]
    auth = [{
      parameters: {
        value: 'vnHQocnOEChoOsYYOHVIn80......EOMmZ63go6s0DzxsAmJaDeE2ljdQjDqJVT'
      }
    }]

    source = @datasift.managed_source.create(
      'facebook_page', 'Ruby test', parameters, resources, auth
    )
    puts source[:data].to_json

    id = source[:data][:id]

    puts "\nStarting delivery for my Managed Source\n--"
    puts @datasift.managed_source.start(id)[:data].to_json

    # Define new resources to be added
    update_resources = [{
      parameters: {
        id: 10513336322,
        title: 'The Guardian'
      }
    }]

    # Push each of the existing resources back into the new resources array
    source[:data][:resources].each do |resource|
      update_resources.push(resource)
    end

    puts "\nUpdating; adding a new resource, and changing the name\n--"
    puts @datasift.managed_source.update(
      id, 'facebook_page', 'Updated Ruby test', source[:data][:parameters],
      update_resources, source[:data][:auth]
    )[:data].to_json

    puts "\nGetting info from DataSift about my source\n--"
    puts @datasift.managed_source.get(id)[:data].to_json

    # Define new resources to add to Managed Source
    new_resources = [
      {
        parameters: {
          id: 5281959998,
          title: 'The New York Times'
        }
      },
      {
        parameters: {
          id: 18468761129,
          title: 'The Huffington Post'
        }
      },
      {
        parameters: {
          id: 97212224368,
          title: 'CNBC'
        }
      }
    ]

    new_auth = [{
      parameters: {
        value: 'CAAIUKbXn8xsBAL7eP......9hcU0b4ZVwlMe9dH5G93Nmvfi2EHJ7nXkRfc7'
      }
    }]

    puts "\nAdding new resources to my source (as an array of Ruby objects)\n--"
    puts @datasift.managed_source_resource.add(
      id, new_resources
    )[:data].to_json

    puts "\nAdding a new token to my source (as an array of Ruby objects)\n--"
    puts @datasift.managed_source_auth.add(id, new_auth)[:data].to_json

    puts "\nGetting info from DataSift about my source (notice the new " \
      "resources and tokens have been added)\n--"
    source = @datasift.managed_source.get id
    puts source[:data].to_json

    puts "\nRemoving a resource from my source by resource_id\n--"
    puts @datasift.managed_source_resource.remove(
      id, [source[:data][:resources][0][:resource_id]]
    )[:data].to_json

    puts "\nRemoving an auth token from my source by identity_id\n--"
    puts @datasift.managed_source_auth.remove(
      id, [source[:data][:auth][0][:identity_id]]
    )[:data].to_json

    puts "\nGetting info from DataSift about my source (notice an auth " \
      "token and resource have been removed)\n--"
    puts @datasift.managed_source.get(id)[:data].to_json

    puts "\nFetching logs (Any error logs for your source will appear here)\n--"
    puts @datasift.managed_source.log(id)[:data].to_json

    puts "\nStopping the Managed Source\n--"
    puts @datasift.managed_source.stop(id)[:data].to_json

    puts "\nDeleting the Managed Source\n--"
    puts @datasift.managed_source.delete(id)[:data].to_json

  rescue DataSiftError => dse
    puts dse.message
  end
end

ManagedSourceApi.new
