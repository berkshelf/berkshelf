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
    "reset@riotgames.com",
    "jkiehl@riotgames.com",
    "michael.ivey@riotgames.com",
    "justin.campbell@riotgames.com"
  ]

  s.description           = %q{Manages a Cookbook's, or an Application's, Cookbook dependencies}
  s.summary               = s.description
  s.homepage              = "http://berkshelf.com"
  s.license               = "Apache 2.0"
  s.files                 = `git ls-files`.split($\)
  s.executables           = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.name                  = "berkshelf"
  s.require_paths         = ["lib"]
  s.version               = Berkshelf::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_dependency 'yajl-ruby'
  s.add_dependency 'activesupport'
  s.add_dependency 'mixlib-shellout'
  s.add_dependency 'mixlib-config'
  s.add_dependency 'faraday', '>= 0.8.5'
  s.add_dependency 'ridley', '>= 0.8.3'
  s.add_dependency 'chozo', '>= 0.6.1'
  s.add_dependency 'hashie', '>= 2.0.2'
  s.add_dependency 'minitar'
  s.add_dependency 'json', '>= 1.5.0'
  s.add_dependency 'multi_json', '~> 1.5'
  s.add_dependency 'solve', '>= 0.4.2'
  s.add_dependency 'thor', '~> 0.16.0'
  s.add_dependency 'retryable'

  # Vagrant 1-0-stable compatability locks
  s.add_dependency 'moneta', '~> 0.6.0'
  s.add_dependency 'net-ssh-gateway', '= 1.1.0'

  s.add_development_dependency 'aruba'
  s.add_development_dependency 'cane'
  s.add_development_dependency 'json_spec'
  s.add_development_dependency 'rake', '>= 0.9.2.2'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'thor'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vagrant', '~> 1.0.6'
end
