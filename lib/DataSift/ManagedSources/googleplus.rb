module DataSift
  class Googleplus < ManagedSource

    def initialize(user, hash)
      @source_type = "googleplus"
      super
    end

  end
end