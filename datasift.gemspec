# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
	s.name    = 'datasift'
	s.version = File.open('VERSION').first

	s.authors     = ['DataSift']
	s.email       = ['support@datasift.net']
	s.description = %q{The official Ruby library for accessing the DataSift API. See http://datasift.com/ for full details and to sign up for an account.}
	s.summary     = %q{DataSift is a simple wrapper for the DataSift API.}
	s.homepage    = 'http://github.com/datasift/datasift-ruby'

	s.platform                  = Gem::Platform::RUBY
	s.rubygems_version          = %q{1.3.6}
	s.required_rubygems_version	= Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=

	s.add_runtime_dependency('rest-client', '~> 1.6.3')
	s.add_runtime_dependency('yajl-ruby', '~> 1.1.0')
	s.add_development_dependency('rdoc', '> 0')
	s.add_development_dependency('shoulda', '~> 2.11.3')
	s.add_development_dependency('rspec', '~> 2.6.0')

	s.files         = `git ls-files`.split("\n")
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.require_paths = ["lib"]
end
