module DataSift
  # Methods for using DataSift Historics
  class Historics < DataSift::ApiResource
    # Prepare a new Historics query
    #
    # @param hash [String] Hash of compiled CSDL filter
    # @param start [Integer] Start timestamp for your Historics Query. Should be
    #   provided as a Unix timestamp
    # @param end_time [Integer] End timestamp for your Historics Query. Should
    #   be provided as a Unix timestamp
    # @param name [String] The name of your Historics query
    # @param sources [String] Comma separated list of data sources you wish to
    #   query
    # @param sample [Integer] Sample size of your Historics query
    # @return [Object] API reponse object
    def prepare(hash, start, end_time, name, sources = 'twitter', sample = 100)
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

    # Pause Historics query
    #
    # @param id [String] ID of the Historics query you need to pause
    # @param reason [String] You can give a reason for pausing the query
    def pause(id, reason = '')
      params = { :id => id }
      requires params
      params[:reason] = reason
      DataSift.request(:PUT, 'historics/pause', @config, params)
    end

    # Resume Historics query
    #
    # @param id [String] ID of the Historics query you need to resume
    def resume(id)
      params = { :id => id }
      requires params
      DataSift.request(:PUT, 'historics/resume', @config, params)
    end

    # Start Historics query
    #
    # @param id [String] ID of the Historics query you need to start
    def start(id)
      params = { :id => id }
      requires params
      DataSift.request(:POST, 'historics/start', @config, params)
    end

    # Stop Historics query
    #
    # @param id [String] ID of the Historics query you need to stop
    # @param reason [String] You can give a reason for stopping the query
    def stop(id, reason = '')
      params = { :id => id }
      requires params
      params[:reason] = reason
      DataSift.request(:POST, 'historics/stop', @config, params)
    end

    # Check the data coverage in the archive for a specified interval
    #
    # @param start [Integer] Start timestamp for the period you wish to query.
    #   Should be provided as a Unix timestamp
    # @param end_time [Integer] End timestamp for the period you wish to query.
    #   Should be provided as a Unix timestamp
    # @param sources [String] Comma separated list of data sources you wish to
    #   query
    def status(start, end_time, sources = 'twitter')
      params = { :start => start, :end => end_time, :sources => sources }
      requires params
      DataSift.request(:GET, 'historics/status', @config, params)
    end

    # Update the name of an Historics query
    #
    # @param id [String] ID of the Historics query you need to update
    # @param name [String] New name for the Historics query
    def update(id, name)
      params = { :id => id, :name => name }
      requires params
      DataSift.request(:POST, 'historics/update', @config, params)
    end

    # Delete an Historics query
    #
    # @param id [String] ID of the Historics query you need to delete
    def delete(id)
      params = { :id => id }
      requires params
      DataSift.request(:DELETE, 'historics/delete', @config, params)
    end

    # Get details for a given Historics query
    #
    # @param id [String] ID of the Historics query you need to get
    # @param with_estimate [Boolean] 1 or 0 indicating whether you want to see
    #   the estimated completion time of the Historics query
    def get_by_id(id, with_estimate = 1)
      params = { :id => id, :with_estimate => with_estimate }
      requires params
      DataSift.request(:GET, 'historics/get', @config, params)
    end

    # Get details for a list of Historics within the given page constraints
    #
    # @param max [Integer] Max number of Historics you wish to return per page
    # @param page [Integer] Which page of results you need returned
    # @param with_estimate [Boolean] 1 or 0 indicating whether you want to see
    #   the estimated completion time of the Historics query
    def get(max = 20, page = 1, with_estimate = 1)
      params = { :max => max, :page => page, :with_estimate => with_estimate }
      requires params
      DataSift.request(:GET, 'historics/get', @config, params)
    end
  end
end
