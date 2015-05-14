module DataSift
  # Methods for using Auth specific Managed Sources API endpoints
  class ManagedSourceResource < DataSift::ApiResource
    # Add resources to a Managed Source
    #
    # @param id [String] ID of the Managed Source you are adding resources to
    # @param resources [Array] Array of resources you are adding to your source
    # @param validate [Boolean] Whether you want to validate your new resources
    #   against the third party API (i.e. the Facebook or Instagram API)
    def add(id, resources, validate = 'true')
      params = {
        id: id,
        resources: resources,
        validate: validate
      }
      requires params
      DataSift.request(:PUT, 'source/resource/add', @config, params)
    end

    # Remove resources from a Managed Source
    #
    # @param id [String] ID of the Managed Source you are removing resources
    #   from
    # @param resource_ids [Array] Array of resource_id strings you need to
    #   remove from your source
    def remove(id, resource_ids)
      params = {
        id: id,
        resource_ids: resource_ids
      }
      requires params
      DataSift.request(:PUT, 'source/resource/remove', @config, params)
    end
  end
end
