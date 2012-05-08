# -*- encoding: utf-8 -*-
require File.expand_path('../lib/knife_cookbook_dependencies/version', __FILE__)

Gem::Specification.new do |s|

  # TODO FIXME need to modify all of these

  s.authors       = ["Josiah Kiehl"]
  s.email         = ["josiah@skirmisher.net"]
  s.description   = %q{Resolves cookbook dependencies}
  s.summary       = s.description
  s.homepage      = "github.com/RiotGames/knife_cookbook_dependencies"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "knife_cookbook_dependencies"
  s.require_paths = ["lib"]
  s.version       = KnifeCookbookDependencies::VERSION
  
  # FIXME will want to adjust this later
  s.add_runtime_dependency 'dep_selector',    '>= 0' 
  s.add_runtime_dependency 'chef',            '~> 0.10.0'
  s.add_runtime_dependency 'minitar',         '>= 0'

  s.add_development_dependency 'rake',        '~> 0.9.0'
  s.add_development_dependency 'rspec',       '>= 0'
  s.add_development_dependency 'rdoc',        '~> 3.0'
  s.add_development_dependency 'simplecov',   '>= 0'
end
