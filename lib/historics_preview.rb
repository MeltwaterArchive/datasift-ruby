module DataSift
  # Methods for using DataSift Historics Previews
  class HistoricsPreview < DataSift::ApiResource
    # Create a new Historics Preview
    #
    # @param hash [String] Hash of compiled CSDL definition
    # @param sources [String] Comma separated list of data sources you wish to
    #   perform this Historics Preview against
    # @param parameters [String] Historics Preview parameters. See our
    #   {http://dev.datasift.com/docs/api/1/previewcreate /preview/create API
    #   Docs} for full documentation
    # @param start [String] Start timestamp for your Historics Preview. Should
    #   be provided as Unix timestamp
    # @param end_time [String] End timestamp for your Historics Preview. Should
    #   be provided as Unix timestamp
    def create(hash, sources, parameters, start, end_time = nil)
      params = {
        :hash       => hash,
        :sources    => sources,
        :parameters => parameters,
        :start      => start
      }
      requires params
      params.merge!(:end => end_time) unless end_time.nil?

      DataSift.request(:POST, 'preview/create', @config, params)
    end

    # Retreive an Historics Preview
    #
    # @param id [String] ID of the Historics Preview
    def get(id)
      params = { :id => id }
      requires params
      DataSift.request(:POST, 'preview/get', @config, params)
    end
  end
end
