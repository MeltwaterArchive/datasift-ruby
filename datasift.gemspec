Gem::Specification.new do |s|
  s.name        = 'datasift'
  s.version     = File.open('VERSION').first
  s.authors     = ['DataSift']
  s.email       = ['support@datasift.com']
  s.description = %q{The official Ruby library for accessing the DataSift API. See http://datasift.com/ for full details and to sign up for an account.}
  s.summary     = %q{DataSift is a simple wrapper for the DataSift API.}
  s.homepage    = 'http://github.com/datasift/datasift-ruby'
  s.license     = 'BSD'

  s.platform         = Gem::Platform::RUBY
  s.rubygems_version = %q{1.3.6}
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=

  s.add_runtime_dependency('rest-client', '~> 1.6.3')
  s.add_development_dependency('multi_json', '~> 1.8.0')
  s.add_runtime_dependency('websocket-eventmachine-client', '~> 1.0.1')
  s.add_runtime_dependency('websocket', '~> 1.1.1')
  s.add_development_dependency('rdoc', '> 0')
  s.add_development_dependency('shoulda', '~> 2.11.3')
  s.add_development_dependency('test-unit', '>= 2.5.5')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end