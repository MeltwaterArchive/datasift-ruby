require 'simplecov'
SimpleCov.start

require File.expand_path('./../../examples/auth', __FILE__)
require 'datasift'
require 'minitest/autorun'
require 'webmock/minitest'
require 'multi_json'
require 'ostruct'

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
