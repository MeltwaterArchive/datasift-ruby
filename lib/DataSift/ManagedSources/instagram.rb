dir = File.dirname(__FILE__)
require dir + '/managed_source'

module DataSift
  class Instagram < ManagedSource

    def initialize(user, hash)
      @source_type = "instagram"
      super
    end

  end
end