# -*- encoding: utf-8; mode: ruby -*-

require File.expand_path('../lib/berkshelf/version', __FILE__)

Gem::Specification.new do |s|
  s.authors               = [
    "Jamie Winsor",
    "Josiah Kiehl",
    "Michael Ivey",
    "Justin Campbell"
  ]
  s.email                 = [
    "jamie@vialstudios.com",
    "josiah@skirmisher.net",
    "ivey@gweezlebur.com",
    "justin@justincampbell.me"
  ]

  s.description           = %q{Manages a Cookbook's, or an Application's, Cookbook dependencies}
  s.summary               = s.description
  s.homepage              = "http://berkshelf.com"
  s.files                 = `git ls-files`.split($\)
  s.executables           = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.name                  = "berkshelf"
  s.require_paths         = ["lib"]
  s.version               = Berkshelf::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_runtime_dependency 'chozo', '>= 0.1.0'
  s.add_runtime_dependency 'ridley', '>= 0.0.5'
  s.add_runtime_dependency 'solve', '>= 0.4.0.rc1'
  s.add_runtime_dependency 'chef', '~> 10.12'
  s.add_runtime_dependency 'minitar'
  s.add_runtime_dependency 'thor', '~> 0.16.0'
  s.add_runtime_dependency 'vagrant', '~> 1.0.5'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'hashie'
  s.add_runtime_dependency 'activemodel'

  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'json_spec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-cucumber'
  s.add_development_dependency 'guard-spork'
  s.add_development_dependency 'guard-yard'
  s.add_development_dependency 'coolline'
  s.add_development_dependency 'rb-fsevent', '~> 0.9.1'
end
