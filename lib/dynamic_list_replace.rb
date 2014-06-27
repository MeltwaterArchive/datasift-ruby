module DataSift
  class DynamicListReplace < DataSift::ApiResource

    ##
    # Start a new replace list
    def start (list_id)
      params = {
          :list_id => list_id
      }
      requires params
      DataSift.request(:POST, 'list/replace/start', @config, params)
    end

    ##
    # Commit the replace list
    def commit (id)
      params = {
          :id => id
      }
      requires params
      DataSift.request(:POST, 'list/replace/commit', @config, params)
    end

    ##
    # Abort the replace list
    def abort (id)
      params = {
          :id => id
      }
      requires params
      DataSift.request(:POST, 'list/replace/abort', @config, params)
    end

    ##
    # Add items to the replace list
    def add (id, items)
      params = {
          :id => id,
          :items => items
      }
      requires params
      DataSift.request(:POST, 'list/replace/add', @config, params)
    end
  end
end