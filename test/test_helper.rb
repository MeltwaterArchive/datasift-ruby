require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/examples/"
  command_name 'Mintest'
end

require 'datasift'
require 'minitest'

require File.expand_path('./../../examples/auth', __FILE__)
require 'minitest/autorun'
require 'webmock/minitest'
require 'multi_json'
require 'ostruct'
require 'vcr'

STATUS = OpenStruct.new(
  valid: 200,
  created: 201,
  accepted: 202,
  no_content: 204,
  bad_request: 400,
  not_found: 404,
  conflict: 409,
  gone: 410
)

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'cassettes')
  c.default_cassette_options = {
    record:                     :new_episodes,
    decode_compressed_response: true,
    serialize_with:             :json,
    preserve_exact_body_bytes:  true
  }
  c.hook_into :webmock
  c.filter_sensitive_data('<USERNAME:API_KEY>') { |interaction| interaction.request.headers['Authorization'].first }
  c.filter_sensitive_data('<BASE64_STRING>') { |interaction| interaction.request.body }
end

include WebMock::API
