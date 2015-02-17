Gem::Specification.new do |s|
  s.name        = 'datasift'
  s.version     = File.open('VERSION').first
  s.authors     = ['DataSift']
  s.email       = ['support@datasift.com']
  s.description = %q{The official Ruby library for accessing the DataSift API. See http://datasift.com/ for full details and to sign up for an account.}
  s.summary     = %q{DataSift is a simple wrapper for the DataSift API.}
  s.homepage    = 'https://github.com/datasift/datasift-ruby'
  s.license     = 'BSD'

  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=

  s.add_runtime_dependency('rest-client', '~> 1.6')
  s.add_runtime_dependency('multi_json', '>= 1.7')
  s.add_runtime_dependency('websocket-td', '~> 0.0.4')

  s.add_development_dependency('rdoc', '>= 0')
  s.add_development_dependency('webmock', '~> 1.17')
  s.add_development_dependency('shoulda', '~> 2.11')
  s.add_development_dependency('minitest', '~> 5.0')
  s.add_development_dependency('rake', '>= 0')
  s.add_development_dependency('simplecov', '>= 0')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ["lib"]
end
