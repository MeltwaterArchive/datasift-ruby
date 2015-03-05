# Custom error class for rescuing DataSift errors
class DataSiftError < StandardError
  attr_reader :status
  attr_reader :body

  def initialize(http_status = nil, http_body = nil)
    @status = http_status
    @body   = http_body
  end

  def message
    @body.nil? ? @status : @body
  end

  def to_s
    # If both body and status were provided then message is the body otherwise
    #   the status contains the message
    msg = !@body.nil? && !@status.nil? ? @body : @status
    # If body is nil then status is the message body so no status is included
    status_string = @body.nil? ? '' : "(Status #{@status}) "
    "#{status_string} : #{msg}"
  end
end

class NotSupportedError < DataSiftError
end

# Standard error returned when receiving a 400 response from the API
class BadRequestError < DataSiftError
end

# Standard error returned when receiving a 401 response from the API
class AuthError < DataSiftError
end

class ConnectionError < DataSiftError
end

# Standard error returned when receiving a 404 response from the API
class ApiResourceNotFoundError < DataSiftError
end

# Standard error returned when receiving a 409 response from the API
class ConflictError < DataSiftError
end

class InvalidConfigError < DataSiftError
end

class InvalidParamError < DataSiftError
end

class NotConnectedError < DataSiftError
end

class ReconnectTimeoutError < DataSiftError
end

class NotConfiguredError < DataSiftError
end

class InvalidTypeError < DataSiftError
end

class StreamingMessageError < DataSiftError
end

class WebSocketOnWindowsError < DataSiftError
end

# Standard error returned when trying to use a method while missing parameters
class BadParametersError < DataSiftError
end
