module DataSift
  class Analysis < DataSift::ApiResource

    def validate(csdl)
      params = {:csdl => csdl}
      requires params
      DataSift.request(:POST, 'analysis/validate', @config, params)
    end

    def compile(csdl)
      params = {:csdl => csdl}
      requires params
      DataSift.request(:POST, 'analysis/compile', @config, params)
    end

    def get(hash = '')
      params = {:hash => hash}
      requires params
      DataSift.request(:GET, 'analysis/get', @config, params)
    end

    def start(hash)
      params = {:hash => hash}
      requires params
      DataSift.request(:PUT, 'analysis/start', @config, params)
    end

    def stop(csdl)
      params = {:hash => hash}
      requires params
      DataSift.request(:PUT, 'analysis/stop', @config, params)
    end

    def analyze(hash, parameters, filter = '', start = '', end = '', include_parameters_in_reply = false)
      params = {
        :hash                         => hash,
        :parameters                   => parameters,
        :filter                       => filter,
        :start                        => start,
        :end                          => end,
        :include_parameters_in_reply  => include_parameters_in_reply
      }
      requires params
      DataSift.request(:POST, 'analysis/analyze', @config, params)
    end

  end
end
