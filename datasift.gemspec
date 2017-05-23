$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'version'

Gem::Specification.new do |s|
  s.name        = 'datasift'
  s.version     = DataSift::VERSION
  s.authors     = ['DataSift', 'Courtney Robinson', 'Jason Dugdale']
  s.email       = ['support@datasift.com']
  s.description = %q{The official Ruby library for accessing the DataSift API. See http://datasift.com/ for full details and to sign up for an account.}
  s.summary     = %q{DataSift is a simple wrapper for the DataSift API.}
  s.homepage    = 'https://github.com/datasift/datasift-ruby'
  s.license     = 'BSD'

  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.5'
  s.required_ruby_version = '>= 2.0.0'
  s.files         = %w(.yardopts CHANGELOG.md README.md datasift.gemspec) + Dir['lib/**/*.rb']
  s.test_files    = s.files.grep(%r{^(test)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rest-client', ['>= 1.8', '< 3.0']
  s.add_runtime_dependency 'multi_json', '~> 1.7'
  s.add_runtime_dependency 'websocket-td', '~> 0.0.5'
  s.add_development_dependency 'bundler', '~> 1.0'
end
