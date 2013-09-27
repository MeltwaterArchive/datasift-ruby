module DataSift
  class ApiResource
    include DataSift

    def initialize (config)
      @config = config
    end

    def requires params
      params.each { |k, v|
        if v == nil || v.to_s.length == 0
          raise InvalidParamError.new "#{k} is a required parameter, it cannot be nil or empty"
        end
      }
    end
  end
end