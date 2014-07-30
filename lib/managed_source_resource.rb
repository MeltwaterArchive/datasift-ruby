module DataSift
  class ManagedSourceResource < DataSift::ApiResource

    def add(id, resources)
      params = {id: id}
      params.merge!({:resources => resources})
      DataSift.request(:POST, 'source/resource/add', @config, params)
    end

    def remove(id, resource_ids)
      params = {id: id}
      params.merge!({:resource_ids => resource_ids})
      DataSift.request(:POST, 'source/resource/remove', @config, params)
    end

  end
end
