module DataSift
  class FacebookPage < ManagedSource

    def initialize(user, hash)
      @source_type = "facebook_page"
      super
    end

  end
end
