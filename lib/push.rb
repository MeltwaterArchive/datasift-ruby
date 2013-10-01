module DataSift
  ##
  # Push is a simple and robust mechanism for periodically delivering your data directly to a given destination
  # Several widely adopted storage locations are available including Amazon S3, FTP, HTTP, SFTP, DynamoDB, CouchDB
  # MongoDB, Splunk, Elastic search and more! See http://dev.datasift.com/docs/push/connectors
  class Push < DataSift::ApiResource

    ##
    # Check that a subscription is defined correctly
    def valid?(params)
      requires params
      res = DataSift.request(:POST, 'push/validate', @config, params)
      res[:http][:status] == 200
    end

    ##
    #Create a new subscription to a live stream or historics query
    # Possible params are
    # hash, playback_id, name, output_type, initial_status, start, end and output_params.*
    # where output_params.* depends on the output_type for specific options see the documentation at
    # http://dev.datasift.com/docs/rest-api/pushcreate
    # For a list of available connectors see http://dev.datasift.com/docs/push/connectors
    def create(params)
      DataSift.request(:POST, 'push/create', @config, params)
    end


    ##
    # Update the name or output parameters for an existing subscription
    def update (params)
      DataSift.request(:POST, 'push/update', @config, params)
    end

    ##
    #Pause a subscription and buffer the data for up to an hour
    def pause(id)
      params = {:id => id}
      requires params
      DataSift.request(:POST, 'push/pause', @config, params)
    end

    ##
    #Restart a job that was previously paused
    def resume(id)
      params = {:id => id}
      requires params
      DataSift.request(:POST, 'push/resume', @config, params)
    end

    ##
    # Stop a historics query or a live stream that is running with push
    def stop(id)
      params = {:id => id}
      requires params
      DataSift.request(:POST, 'push/stop', @config, params)
    end

    ##
    # Deletes an existing push subscription
    def delete(id)
      params = {:id => id}
      requires params
      DataSift.request(:POST, 'push/delete', @config, params)
    end

    ##
    # Retrieve log messages for a specific subscription
    def logs_for (id, page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :id        => id,
          :page      => page,
          :per_page  => per_page,
          :order_by  => order_by,
          :order_dir => order_dir
      }
      DataSift.request(:POST, 'push/log', @config, params)
    end

    ##
    # Retrieve log messages for all subscriptions
    def logs (page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :page      => page,
          :per_page  => per_page,
          :order_by  => order_by,
          :order_dir => order_dir
      }
      DataSift.request(:POST, 'push/log', @config, params)
    end

    ##
    # Get details of the subscription with the given ID
    def get_by_subscription(id, page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :id        => id,
          :page      => page,
          :per_page  => per_page,
          :order_by  => order_by,
          :order_dir => order_dir
      }
      DataSift.request(:POST, 'push/get', @config, params)
    end

    ##
    # Get details of the subscription with the given stream ID/hash
    def get_by_hash(hash, page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :hash      => hash,
          :page      => page,
          :per_page  => per_page,
          :order_by  => order_by,
          :order_dir => order_dir
      }
      DataSift.request(:POST, 'push/get', @config, params)
    end

    ##
    # Get details of the subscription with the given Historics ID
    def get_by_historics_id(id, page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :historics_id => id,
          :page         => page,
          :per_page     => per_page,
          :order_by     => order_by,
          :order_dir    => order_dir
      }
      DataSift.request(:POST, 'push/get', @config, params)
    end

    ##
    # Get details of all subscriptions within the given page constraints
    def get(page = 1, per_page = 20, order_by = :request_time, order_dir = :desc)
      params = {
          :page      => page,
          :per_page  => per_page,
          :order_by  => order_by,
          :order_dir => order_dir
      }
      DataSift.request(:POST, 'push/get', @config, params)
    end
  end
end