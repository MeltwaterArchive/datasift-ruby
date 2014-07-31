module DataSift
  class ManagedSourceResource < DataSift::ApiResource

    def add(id, resources, validate = 'true')
      params = {
        id:       id,
        validate: validate
      }
      params.merge!({:resources => resources})
      DataSift.request(:PUT, 'source/resource/add', @config, params)
    end

    def remove(id, resource_ids)
      params = {id: id}
      params.merge!({:resource_ids => resource_ids})
      DataSift.request(:PUT, 'source/resource/remove', @config, params)
    end

  end
end
