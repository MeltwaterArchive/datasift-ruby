module DataSift
  class ManagedSourceAuth < DataSift::ApiResource

    def add(id, auth, validate = 'true')
      params = {
        id:       id,
        validate: validate
      }
      params.merge!({:auth => auth})
      DataSift.request(:PUT, 'source/auth/add', @config, params)
    end

    def remove(id, auth_ids)
      params = {id: id}
      params.merge!({:auth_ids => auth_ids})
      DataSift.request(:PUT, 'source/auth/remove', @config, params)
    end

  end
end
