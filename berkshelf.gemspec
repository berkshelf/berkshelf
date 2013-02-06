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
  s.add_dependency 'chef', '>= 10.16.2', '<= 11.0.1'
  s.add_dependency 'ridley', '~> 0.6.3'
  s.add_dependency 'chozo', '>= 0.2.3'
  s.add_dependency 'hashie'
  s.add_dependency 'minitar'
  s.add_dependency 'multi_json', '>= 1.3.0'
  s.add_dependency 'solve', '>= 0.4.0.rc1'
  s.add_dependency 'thor', '~> 0.16.0'
  s.add_dependency 'vagrant', '~> 1.0.5'
end
