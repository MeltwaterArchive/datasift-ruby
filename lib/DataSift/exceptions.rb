module DataSift
	# All exceptions inherit from DataSiftError.
	class DataSiftError < StandardError; end

	# Thrown when access to the API is denied.
	class AccessDeniedError < DataSiftError; end

	# Thrown when CSDL validation or compilation fails.
	class CompileFailedError < DataSiftError; end

	# Thrown whenever invalid data is encountered in the library.
	class InvalidDataError < DataSiftError; end

	# Thrown when you exceed your API rate limit.
	class RateLimitExceededError < DataSiftError; end

	# Thrown when error occur while reading streaming data.
	class StreamError < DataSiftError; end

	#Thrown when an error is found in API responses.
	#These errors optionally carry the HTTP error code.
	class APIError < DataSiftError
		#The HTTP status code.
		attr_reader :http_code

		#Constructor.
		#=== Parameters
		#* +http_code+ - Optional HTTP status code.
		def initialize(http_code = -1)
			@http_code = http_code
		end
	end
end
