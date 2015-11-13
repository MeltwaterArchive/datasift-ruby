module DataSift
  ##
  # Use DataSift's Open Data Processing (ODP) to upload your own data to
  #   DataSift for processing
  class Odp < DataSift::ApiResource
    def ingest(source_id, data)
      fail ArgumentError, 'source_id is required' if source_id.nil?
      fail ArgumentError, 'data payload is required' if data.nil?

      DataSift.request(
        :POST,
        source_id,
        @config.merge(api_host: @config[:ingestion_host], api_version: nil),
        data
      )
    end
  end
end
