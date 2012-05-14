# -*- encoding: utf-8; mode: ruby -*-

require File.expand_path('../lib/kcd/version', __FILE__)

Gem::Specification.new do |s|
  # TODO FIXME need to modify all of these
  s.authors       = ["Josiah Kiehl", "Jamie Winsor", "Erik Hollensbe"]
  s.email         = ["josiah@skirmisher.net", "jamie@vialstudios.com", "erik@hollensbe.org"]
  s.description   = %q{Resolves cookbook dependencies}
  s.summary       = s.description
  s.homepage      = "https://github.com/RiotGames/knife_cookbook_dependencies"
  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "knife_cookbook_dependencies"
  s.require_paths = ["lib"]
  s.version       = KnifeCookbookDependencies::VERSION
  
  # FIXME will want to adjust this later
  s.add_runtime_dependency 'dep_selector'
  s.add_runtime_dependency 'chef',            '~> 0.10.0'
  s.add_runtime_dependency 'minitar'

  s.add_development_dependency 'webmock'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rake',        '~> 0.9.0'
  s.add_development_dependency 'rdoc',        '~> 3.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-spork'
end
