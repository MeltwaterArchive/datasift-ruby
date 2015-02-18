require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/examples/"
end

require 'datasift'
require 'minitest'

require File.expand_path('./../../examples/auth', __FILE__)
require 'minitest/autorun'
require 'webmock/minitest'
require 'multi_json'
require 'ostruct'
require 'vcr'

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
end

include WebMock::API
