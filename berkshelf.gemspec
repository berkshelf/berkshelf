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
    'justin@justincampbell.me',
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
  s.required_ruby_version     = '>= 1.9.2'
  s.required_rubygems_version = '>= 1.8.0'

  s.add_dependency 'addressable',          '~> 2.3.4'
  s.add_dependency 'berkshelf-api-client', '~> 1.1'
  s.add_dependency 'buff-config',          '~> 0.2'
  s.add_dependency 'buff-extensions',      '~> 0.4'
  s.add_dependency 'buff-shell_out',       '~> 0.1'
  s.add_dependency 'faraday',              '~> 0.8.5'
  s.add_dependency 'minitar',              '~> 0.5.4'
  s.add_dependency 'retryable',            '~> 1.3.3'
  s.add_dependency 'ridley',               '~> 2.3'
  s.add_dependency 'solve',                '>= 0.8.0'
  s.add_dependency 'thor',                 '~> 0.18.0'
  s.add_dependency 'octokit',              '~> 2.6'

  s.add_development_dependency 'aruba',         '~> 0.5'
  s.add_development_dependency 'chef-zero',     '~> 1.5.0'
  s.add_development_dependency 'fuubar',        '~> 1.1'
  s.add_development_dependency 'rake',          '~> 0.9'
  s.add_development_dependency 'rspec',         '~> 2.13'
  s.add_development_dependency 'spork',         '~> 0.9'
  s.add_development_dependency 'webmock',       '~> 1.11'
  s.add_development_dependency 'yard',          '~> 0.8'
end
