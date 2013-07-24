dir = File.dirname(__FILE__)
require dir + '/managed_source'
module DataSift
  class FacebookPage < ManagedSource

    def initialize(user, hash)
      @source_type = "facebook_page"
      super
    end

  end
end
