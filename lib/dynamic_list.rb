module DataSift
  class DynamicList < DataSift::ApiResource

    ##
    # Get all lists and their ids.
    def get
      params = {}
      requires params
      DataSift.request(:GET, 'list/get', @config, params)
    end

    ##
    # Create a new dynamic list
    def create (type, name)
      params = {
          :type => type
      }
      requires params
      params[:name] = name
      DataSift.request(:POST, 'list/create', @config, params)
    end

    ##
    # Delete a dynamic list
    def delete (id)
      params = {
          :id => id
      }
      requires params
      DataSift.request(:POST, 'list/delete', @config, params)
    end

    ##
    # Check if items exist in given list
    def exists (id, items)
      params = {
          :id => id,
          :items => items
      }
      requires params
      DataSift.request(:POST, 'list/exists', @config, params)
    end

    ##
    # Add items to a given list
    def add (id, items)
      params = {
          :id => id,
          :items => items
      }
      requires params
      DataSift.request(:POST, 'list/add', @config, params)
    end

    ##
    # Remove items from a given list
    def remove (id, items)
      params = {
          :id => id,
          :items => items
      }
      requires params
      DataSift.request(:POST, 'list/remove', @config, params)
    end
  end
end
