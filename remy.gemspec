# -*- encoding: utf-8 -*-
require File.expand_path('../lib/remy/version', __FILE__)

Gem::Specification.new do |gem|

  # TODO FIXME need to modify all of these

  gem.authors       = ["Josiah Kiehl"]
  gem.email         = ["bluepojo@gmail.com"]
  gem.description   = %q{A Chef Cookbook Manager}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "remy"
  gem.require_paths = ["lib"]
  gem.version       = Remy::VERSION
  
  # FIXME will want to adjust this later
  gem.add_runtime_dependency 'dep_selector', '>= 0' 
  gem.add_runtime_dependency 'chef',         '~> 0.10.0'
  gem.add_runtime_dependency 'minitar',      '>= 0'

  gem.add_development_dependency 'rake',     '~> 0.9.0'
  gem.add_development_dependency 'rspec',    '>= 0'
  gem.add_development_dependency 'rdoc',     '~> 3.0'
end
