# -*- encoding: utf-8; mode: ruby -*-
require File.expand_path('../lib/berkshelf/version', __FILE__)

Gem::Specification.new do |s|
  s.authors               = [
    'Jamie Winsor',
    'Josiah Kiehl',
    'Michael Ivey',
    'Justin Campbell',
    'Seth Vargo'
  ]
  s.email                 = [
    'jamie@vialstudios.com',
    'jkiehl@riotgames.com',
    'michael.ivey@riotgames.com',
    'justin.campbell@riotgames.com',
    'sethvargo@gmail.com'
  ]

  s.description               = %q{Manages a Cookbook's, or an Application's, Cookbook dependencies}
  s.summary                   = s.description
  s.homepage                  = 'http://berkshelf.com'
  s.license                   = 'Apache 2.0'
  s.files                     = `git ls-files`.split($\)
  s.executables               = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files                = s.files.grep(%r{^(test|spec|features)/})
  s.name                      = 'berkshelf'
  s.require_paths             = ['lib']
  s.version                   = Berkshelf::VERSION
  s.required_ruby_version     = '>= 1.9.1'
  s.required_rubygems_version = '>= 1.8.0'

  s.add_dependency 'activesupport',     '~> 3.2.0'
  s.add_dependency 'addressable',       '~> 2.3.4'
  s.add_dependency 'buff-shell_out',    '~> 0.1'
  s.add_dependency 'chozo',             '>= 0.6.1'
  s.add_dependency 'faraday',           '~> 0.8.5'
  s.add_dependency 'hashie',            '>= 2.0.2'
  s.add_dependency 'minitar',           '~> 0.5.4'
  s.add_dependency 'retryable',         '~> 1.3.3'
  s.add_dependency 'ridley',            '~> 1.5.0'
  s.add_dependency 'solve',             '>= 0.5.0'
  s.add_dependency 'thor',              '~> 0.18.0'
  s.add_dependency 'rbzip2',            '~> 0.2.0'
  s.add_dependency 'faraday',           '~> 0.8.0' # lock tranisitive dependency of Ridley

  s.add_development_dependency 'aruba',         '~> 0.5'
  s.add_development_dependency 'cane',          '~> 2.5'
  s.add_development_dependency 'chef-zero',     '~> 1.5.0'
  s.add_development_dependency 'fuubar',        '~> 1.1'
  s.add_development_dependency 'rake',          '~> 0.9'
  s.add_development_dependency 'rspec',         '~> 2.13'
  s.add_development_dependency 'simplecov',     '~> 0.7'
  s.add_development_dependency 'spork',         '~> 0.9'
  s.add_development_dependency 'vcr',           '~> 2.4'
  s.add_development_dependency 'webmock',       '~> 1.11'
  s.add_development_dependency 'yard',          '~> 0.8'

  # Guard extensions for development
  s.add_development_dependency 'coolline',      '~> 0.4.2' # readline for guard on MRI
  s.add_development_dependency 'guard',         '~> 1.8'
  s.add_development_dependency 'guard-cane'
  s.add_development_dependency 'guard-cucumber'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-spork'
  s.add_development_dependency 'guard-yard'
end
