module DataSift
  class ManagedSource < DataSift::ApiResource

    ##
    # Creates a new managed source
    #+source_type+:: can be facebook_page, googleplus, instagram or yammer
    def create(source_type, name, parameters = {}, resources = [], auth = [])
      params = {
          :source_type => source_type,
          :name        => name
      }
      params.merge!({:auth => auth.is_a?(String) ? auth : MultiJson.dump(auth)}) unless auth.empty?
      params.merge!({:parameters => parameters.is_a?(String) ? parameters : MultiJson.dump(parameters)}) unless parameters.empty?
      params.merge!({:resources => resources.is_a?(String) ? resources : MultiJson.dump(resources)}) if resources.length > 0
      puts params
      exit 0
      DataSift.request(:POST, 'source/create', @config, params)
    end

    def update(id, source_type, name, parameters = {}, resources = [], auth = [])
      params = {
          :id          => id,
          :source_type => source_type,
          :name        => name
      }
      params.merge!({:auth => MultiJson.dump(auth)}) if !auth.empty?
      params.merge!({:parameters => MultiJson.dump(parameters)}) if !parameters.empty?
      params.merge!({:resources => MultiJson.dump(resources)}) if resources.length > 0

      DataSift.request(:POST, 'source/update', @config, params)
    end

    def delete(id)
      DataSift.request(:DELETE, 'source/delete', @config, {:id => id})
    end

    def stop(id)
      DataSift.request(:POST, 'source/stop', @config, {:id => id})
    end

    def start(id)
      DataSift.request(:POST, 'source/start', @config, {:id => id})
    end

    def get(id = nil, source_type = nil, page = 1, per_page = 20)
      params = {:page => page, :per_page => per_page}
      params.merge!({:id => id}) if id != nil
      params.merge!({:source_type => source_type}) if source_type != nil

      DataSift.request(:GET, 'source/get', @config, params)
    end

    def log(id, page = 1, per_page = 20)
      DataSift.request(:POST, 'source/get', @config, {:id => id, :page => page, :per_page => per_page})
    end

  end
end
