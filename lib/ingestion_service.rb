module DataSift
  
  class IngestionService < DataSift::ApiResource
        
    def ingest(source_id, data)
      config = @config.merge(api_host: "in.datasift.com", api_version: nil)
      DataSift.request(:POST, "/#{source_id}", config, data)
    end

  end
  
end
