dir = File.dirname(__FILE__)
require dir + '/managed_source'
module DataSift
  class Googleplus < ManagedSource

    def initialize(user, hash)
      @source_type = "googleplus"
      super
    end

  end
end