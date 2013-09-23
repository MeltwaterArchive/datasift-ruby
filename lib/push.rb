module DataSift
  ##
  # Push is a simple and robust mechanism for periodically delivering your data directly to a given destination
  # Several widely adopted storage locations are available including Amazon S3, FTP, HTTP, SFTP, DynamoDB, CouchDB
  # MongoDB, Splunk, Elastic search and more! See http://dev.datasift.com/docs/push/connectors
  class Push < DataSift::ApiResource

    ##
    # Check that a subscription is defined correctly
    def validate?

    end

    ##
    #Create a new subscription to a live stream or historics query
    def create

    end

    ##
    #Pause a subscription and buffer the data for up to an hour
    def pause

    end

    ##
    #Restart a job that was previously paused
    def resume

    end

    ##
    # Update the name or output parameters for an existing subscription
    def update

    end

    ##
    # Stop a historics query or a live stream that is running with push
    def stop

    end

    ##
    # Deletes an existing push subscription
    def delete

    end

    ##
    # Retrieve details from the message log
    def log

    end

    ##
    # Show details of the subscriptions belonging to this user
    def get

    end

    ##
    # Collect a batch of interactions from a push queue
    def pull

    end
  end
end