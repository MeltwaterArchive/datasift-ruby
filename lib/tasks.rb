module DataSift
  #
  # Class for accessing DataSift's Tasks API
  class Task < DataSift::ApiResource
    # Creates a Task; this call requires use of an identity API key
    #
    # @param service [String] Service you wish to create a Task for
    # @param type [String] Type of Task to be run
    # @param subscription_id [String] Subscription ID as returned by /pylon/start
    # @param name [String] Human identifier for this Task
    # @param parameters [Hash] Object representing the parameters for the Task type
    # @return [Object] API reponse object
    def create(service:, type:, subscription_id:, name:, parameters:)
      DataSift.request(:POST, "pylon/#{service}/task", @config, {
        type: type,
        subscription_id: subscription_id,
        name: name,
        parameters: parameters
      })
    end

    # Gets a single task by ID; this call requires use of the identity API key associated with the
    #   Task requested
    #
    # @param service [String] Service of the Task you wish to return
    # @param type [String] (Optional) Type of Task to be run (Default: 'analysis')
    # @param id [String] ID of the Task you wish to return
    # @return [Object] API reponse object
    def get(service:, type: 'analysis', id:)
      DataSift.request(:GET, "pylon/#{service}/task/#{type}/#{id}", @config)
    end

    # Gets a list of all current Tasks on the service. This call may be accessed using either a
    #   main or identity-level API key.
    #
    # @param service [String] Search Tasks by Service
    # @param type [String] (Optional) Type of Task to be run (Default: 'analysis')
    # @param per_page [Integer] (Optional) How many Tasks should be returned per page of results
    # @param page [Integer] (Optional) Which page of results to return
    # @param status [String] (Optional) Filter by Tasks on Status
    # @return [Object] API reponse object
    def list(service:, type: 'analysis', **opts)
      params = {}
      params[:per_page] = opts[:per_page] if opts.key?(:per_page)
      params[:page] = opts[:page] if opts.key?(:page)
      params[:status] = opts[:status] if opts.key?(:status)

      DataSift.request(:GET, "pylon/#{service}/task/#{type}", @config, params)
    end
  end
end
