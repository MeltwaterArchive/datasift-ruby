module DataSift
	class DataSiftError < StandardError; end

	class AccessDeniedError < DataSiftError; end
	class CompileFailedError < DataSiftError; end
	class InvalidDataError < DataSiftError; end
	class NotYetImplementedError < DataSiftError; end
	class RateLimitExceededError < DataSiftError; end
	class StreamError < DataSiftError; end

	class APIError < DataSiftError
		attr_reader :http_code

		def initialize(http_code = -1)
			@http_code = http_code
		end
	end
end
