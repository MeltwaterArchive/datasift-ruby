module DataSift
  ##
  # Push is a simple and robust mechanism for periodically delivering your data
  #   directly to a given destination. Several widely adopted storage locations
  #   are available including Amazon S3, (S)FTP, HTTP, DynamoDB, CouchDB,
  #   MongoDB, Splunk, ElasticSearch and more! See
  #   http://dev.datasift.com/docs/push/connectors
  class Push < DataSift::ApiResource
    ##
    # Check that a Push subscription definition is valid
    #
    # @param params [Hash] Hash of Push subscription parameters
    # @param bool_response [Boolean] True if you want a boolean response. False
    #   if you want the full response object
    def valid?(params, bool_response = true)
      requires params
      res = DataSift.request(:POST, 'push/validate', @config, params)
      bool_response ? res[:http][:status] == 200 : res
    end

    # Create a new subscription to a live stream or historics query. Possible
    #   params are hash, historics_id, name, output_type, initial_status, start,
    #   end and output_params.* where output_params.* depends on the output_type
    #   for specific options see the documentation at
    #   http://dev.datasift.com/docs/rest-api/pushcreate For a list of available
    #   connectors see http://dev.datasift.com/docs/push/connectors
    #
    # @param params [Hash] Hash of Push subscription parameters
    def create(params)
      DataSift.request(:POST, 'push/create', @config, params)
    end

    # Update the name or output parameters for an existing subscription
    #
    # @param params [Hash] Hash of Push subscription parameters
    def update(params)
      DataSift.request(:POST, 'push/update', @config, params)
    end

    # Pause a subscription and buffer the data for up to an hour
    #
    # @param id [String] ID of the Push subscription to pause
    def pause(id)
      params = { :id => id }
      requires params
      DataSift.request(:PUT, 'push/pause', @config, params)
    end

    # Resume a Push subscription that was previously paused
    #
    # @param id [String] ID of the Push subscription to resume
    def resume(id)
      params = { :id => id }
      requires params
      DataSift.request(:PUT, 'push/resume', @config, params)
    end

    # Stop a Push subscription; you will not be able to resume this
    #
    # @param id [String] ID of the Push subscription to stop
    def stop(id)
      params = { :id => id }
      requires params
      DataSift.request(:PUT, 'push/stop', @config, params)
    end

    # Deletes an existing push subscription
    #
    # @param id [String] ID of the Push subscription to delete
    def delete(id)
      params = {:id => id}
      requires params
      DataSift.request(:DELETE, 'push/delete', @config, params)
    end

    # Retrieve log messages for a specific subscription
    #
    # @param id [String] ID of the Push subscription to retrieve logs for
    # @param page [Integer] Which page of logs to retreive
    # @param per_page [Integer] How many logs to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    def log_for(id, page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
        :id => id
      }
      requires params
      params.merge!(
        :page => page,
        :per_page => per_page,
        :order_by => order_by,
        :order_dir => order_dir
      )
      DataSift.request(:GET, 'push/log', @config, params)
    end

    # Retrieve log messages for all subscriptions
    #
    # @param page [Integer] Which page of logs to retreive
    # @param per_page [Integer] How many logs to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    def log(page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
        :page => page,
        :per_page => per_page,
        :order_by => order_by,
        :order_dir => order_dir
      }
      DataSift.request(:GET, 'push/log', @config, params)
    end

    # Get details of the subscription with the given ID
    #
    # @param id [String] ID of the subscription to retrieve
    def get_by_subscription(id)
      params = { :id => id }
      DataSift.request(:GET, 'push/get', @config, params)
    end

    # Get details of the subscription with the given filter hash
    #
    # @param hash [String] CSDL filter hash
    # @param page [Integer] Which page of logs to retreive
    # @param per_page [Integer] How many logs to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    def get_by_hash(hash, page = 1, per_page = 20, order_by = :created_at, order_dir = :desc)
      params = {
        :hash => hash
      }
      requires params
      params.merge!(
        :page => page,
        :per_page => per_page,
        :order_by => order_by,
        :order_dir => order_dir
      )
      DataSift.request(:GET, 'push/get', @config, params)
    end

    # Get details of the subscription with the given Historics ID
    #
    # @param historics_id [String] ID of the Historics query for which you are
    #   searching for the related Push subscription
    # @param page [Integer] Which page of logs to retreive
    # @param per_page [Integer] How many logs to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    def get_by_historics_id(historics_id, page = 1, per_page = 20, order_by = :created_at, order_dir = :desc)
      params = {
        :historics_id => historics_id,
        :page => page,
        :per_page => per_page,
        :order_by => order_by,
        :order_dir => order_dir
      }
      DataSift.request(:GET, 'push/get', @config, params)
    end

    # Get details of all subscriptions within the given page constraints
    #
    # @param page [Integer] Which page of logs to retreive
    # @param per_page [Integer] How many logs to return per page
    # @param order_by [String, Symbol] Which field to sort results by
    # @param order_dir [String, Symbol] Order results in ascending or descending
    def get(page = 1, per_page = 20, order_by = :created_at, order_dir = :desc)
      params = {
        :page => page,
        :per_page => per_page,
        :order_by => order_by,
        :order_dir => order_dir
      }
      DataSift.request(:GET, 'push/get', @config, params)
    end

    # Pull data from a 'pull' type Push Subscription
    #
    # @param id [String] ID of the Push subscription to pull data from
    # @param size [Integer] Max size (bytes) of the data that should be returned
    # @param cursor [String] Point to a specific point in your Push buffer using
    #   a cursor
    # @param callback [Method] Pass a callback to process each interaction
    #   returned from a successful pull request
    def pull(id, size = 52_428_800, cursor = '', callback = nil)
      params = {
        :id => id
      }
      requires params
      params.merge!(
        :size => size,
        :cursor => cursor
      )
      params.merge!({:on_interaction => callback}) unless callback.nil?
      DataSift.request(:GET, 'pull', @config, params, {}, 30, 30, true)
    end
  end
end
