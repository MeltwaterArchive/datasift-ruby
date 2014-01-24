module DataSift
  class HistoricsPreview < DataSift::ApiResource

    def create(hash, parameters, start, end_time = nil)
      params = {
          :hash       => hash,
          :parameters => parameters,
          :start      => start
      }
      params.merge!(:end => end_time) if end_time != nil

      DataSift.request(:POST, 'preview/create', @config, params)
    end

    def get(id)
      DataSift.request(:POST, 'preview/get', @config, {:id => id})
    end

  end
end
