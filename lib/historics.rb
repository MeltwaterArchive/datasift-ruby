module DataSift
  class Historics < DataSift::ApiResource

    ##
    # Create a new historics query and return its id.
    def prepare (hash, start, end_time, name, sources = 'twitter', sample = 100)
      params = {
          :hash => hash,
          :start => start,
          :end => end_time,
          :name => name,
          :sources => sources,
          :sample => sample
      }
      requires params
      DataSift.request(:POST, 'historics/prepare', @config, params)
    end

    ##
    # Starts historics query.
    def start(id)
      params = {:id => id}
      requires params
      DataSift.request(:POST, 'historics/start', @config, params)
    end

    ##
    # Stop historics query.
    def stop(id, reason = '')
      params = {:id => id}
      requires params
      params[:reason] = reason
      DataSift.request(:POST, 'historics/stop', @config, params)
    end

    ##
    # Check the data coverage in the archive for a specified interval.
    def status(start, end_time, sources='twitter')
      params = {:start => start, :end => end_time, :sources => sources}
      requires params
      DataSift.request(:GET, 'historics/status', @config, params)
    end

    ##
    # Update a historics query's name.
    def update(id, name)
      params = {:id => id, :name => name}
      requires params
      DataSift.request(:POST, 'historics/update', @config, params)
    end

    ##
    # Delete a historics query.
    def delete(id)
      params = {:id => id}
      requires params
      DataSift.request(:DELETE, 'historics/delete', @config, params)
    end

    ##
    # Get details for a given historics query.
    def get_by_id(id, with_estimate = 1)
      params = {:id => id, :with_estimate => with_estimate}
      requires params
      DataSift.request(:GET, 'historics/get', @config, params)
    end

    ##
    # Get details for a set of historics within the given page constraints.
    def get(max=20, page=1, with_estimate = 1)
      params = {:max => max, :page => page, :with_estimate => with_estimate}
      requires params
      DataSift.request(:GET, 'historics/get', @config, params)
    end

  end
end
