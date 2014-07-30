module DataSift
  class ManagedSourceAuth < DataSift::ApiResource

    def add(id, auth)
      params = {id: id}
      params.merge!({:auth => auth})
      DataSift.request(:POST, 'source/auth/add', @config, params)
    end

    def remove(id, auth_ids)
      params = {id: id}
      params.merge!({:auth_ids => auth_ids})
      DataSift.request(:POST, 'source/auth/remove', @config, params)
    end

  end
end
