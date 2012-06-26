# -*- encoding: utf-8; mode: ruby -*-

require File.expand_path('../lib/berkshelf/version', __FILE__)

Gem::Specification.new do |s|
  s.authors               = ["Josiah Kiehl", "Jamie Winsor", "Michael Ivey", "Erik Hollensbe"]
  s.email                 = ["josiah@skirmisher.net", "jamie@vialstudios.com", "ivey@gweezlebur.com", "erik@hollensbe.org"]
  s.description           = %q{Manages a Cookbook's, or an Application's, Cookbook dependencies}
  s.summary               = s.description
  s.homepage              = "https://github.com/RiotGames/berkshelf"
  s.files                 = `git ls-files`.split($\)
  s.executables           = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.name                  = "berkshelf"
  s.require_paths         = ["lib"]
  s.version               = Berkshelf::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_runtime_dependency 'dep_selector'
  s.add_runtime_dependency 'chef',            '~> 10.12.0'
  s.add_runtime_dependency 'minitar'
  s.add_runtime_dependency 'thor',            '~> 0.15.2'

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
end
