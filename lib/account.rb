module DataSift
  #
  # Class for accessing DataSift's Account API
  class Account < DataSift::ApiResource
    # Check your account usage for a given period and timeframe
    #
    # @param period [String] (Optional) Period is one of either hourly, daily or monthly
    # @param start_time [Integer] (Optional) Unix timestamp of the start of the period
    #   you are querying
    # @param end_time [Integer] (Optional) Unix timestamp of the end of the period
    #   you are querying
    # @return [Object] API reponse object
    def usage(start_time, end_time, period = '')
      params = { start: start_time, end: end_time }
      params.merge!(period: period) unless period.empty?

      DataSift.request(:GET, 'account/usage', @config, params)
    end
  end
end
