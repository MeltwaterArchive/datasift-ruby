module DataSift
	class AccessDeniedError < StandardError; end
	class CompileFailedError < StandardError; end
	class InvalidDataError < StandardError; end
	class NotYetImplementedError < StandardError; end
	class RateLimitExceededError < StandardError; end
	class StreamError < StandardError; end

	class APIError < StandardError
		attr_reader :http_code

		def initialize(http_code)
			@http_code = http_code
		end
	end
end
