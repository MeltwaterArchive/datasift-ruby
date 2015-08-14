module DataSift
  ##
  # Use DataSift's Open Data Processing (ODP) to upload your own data to
  #   DataSift for processing
  class Odp < DataSift::ApiResource
    def ingest(source_id, data)
      config = @config.merge(api_host: @config[:ingestion_host], api_version: nil)
      DataSift.request(:POST, source_id, config, data)
    end
  end
end
