# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'capistrano/srv_hosts/version'

Gem::Specification.new do |s|
  s.name            = "capistrano-srv_hosts"
  s.version         = Capistrano::SrvHosts::VERSION
  s.platform        = Gem::Platform::RUBY
  s.authors         = ["Tuomas Silen"]
  s.email           = ["tsilen@rallydev.com"]
  s.homepage        = ""
  s.license         = "MIT"
  s.summary         = %q{Capistrano extension to fetch deploy hosts via DNS}
  s.description     = %q{Allows capistrano to configure deploy hosts and roles using DNS SRV records}

  s.files           = `git ls-files`.split($/)
  s.executables     = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths   = ["lib"]

  s.add_dependency 'capistrano', '~> 3.0'
  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.13'
end
