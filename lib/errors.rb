class DataSiftError < StandardError
  attr_reader :http_status
  attr_reader :http_body

  def initialize(http_status = nil, http_body = nil)
    @http_status = http_status
    @http_body   = http_body
  end

  def message
    :http_body == nil ? @http_status : @http_body
  end

  def to_s
    #if both body and status were provided then message is the body otherwise the status contains the message
    msg           = !@http_body.nil? && !@http_status.nil? ? @http_body : @http_status
    #if body is nil then status is the message body so no status is included
    status_string = @http_body.nil? ? '' : "(Status #{@http_status}) "
    "#{status_string} : #{msg}"
  end
end

class NotSupportedError < DataSiftError
end

class BadRequestError < DataSiftError
end

class AuthError < DataSiftError
end

class ConnectionError < DataSiftError
end

class ApiResourceNotFoundError < DataSiftError
end

class InvalidConfigError < DataSiftError
end

class InvalidParamError < DataSiftError
end