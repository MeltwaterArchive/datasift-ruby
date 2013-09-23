dir = File.dirname(__FILE__)
#
require dir + '/api/api_resource'
#
require dir + '/core'
require dir + '/push'
require dir + '/historics'
require dir + '/managed_source'

module DataSift
  @@api_url = 'https://api.datasift.com/'
  @@stream_url = 'ws://websocket.datasift.com/'

  class Client
    def initialize (username, api_key)
      @username = username
      @api_key = api_key

      @core = DataSift::Core.new(username, api_key)
      @historics = DataSift::Historics.new(username, api_key)
      @push = DataSift::Push.new(username, api_key)
      @managed_source = DataSift::ManagedSource.new(username, api_key)
    end

    attr_reader :core, :historics, :push, :managed_source
  end

  def self.request(method, url, username, api_key, params = {}, headers = {})

    case method.to_s.downcase.to_sym
      when :get
      when :post
      else
        raise NotSupportedError.new ('#{method} is not currently supported')
    end
  end
end