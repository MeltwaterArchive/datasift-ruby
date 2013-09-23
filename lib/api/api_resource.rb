module DataSift
  class ApiResource
    # mix-in the API methods
    include DataSift

    def initialize (username, api_key)
      @username = username
      @api_key = api_key
    end
  end
end