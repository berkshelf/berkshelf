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
  s.required_ruby_version     = '>= 2.0.0'
  s.required_rubygems_version = '>= 1.8.0'

  s.add_dependency 'addressable',          '~> 2.3.4'
  s.add_dependency 'berkshelf-api-client', '~> 2.0'
  s.add_dependency 'buff-config',          '~> 1.0'
  s.add_dependency 'buff-extensions',      '~> 1.0'
  s.add_dependency 'buff-shell_out',       '~> 0.1'
  s.add_dependency 'cleanroom',            '~> 1.0'
  s.add_dependency 'faraday',              '~> 0.9.0'
  s.add_dependency 'httpclient',           '~> 2.6.0'
  s.add_dependency 'minitar',              '~> 0.5.4'
  s.add_dependency 'retryable',            '~> 2.0'
  s.add_dependency 'ridley',               '~> 4.3'
  s.add_dependency 'solve',                '~> 1.1'
  s.add_dependency 'thor',                 '~> 0.19'
  s.add_dependency 'octokit',              '~> 3.0'
  s.add_dependency 'celluloid',            '= 0.16.0'
  s.add_dependency 'celluloid-io',         '~> 0.16.1'

  s.add_development_dependency 'aruba',         '~> 0.6'
  s.add_development_dependency 'chef-zero',     '~> 1.5.0'
  s.add_development_dependency 'fuubar',        '~> 1.1'
  s.add_development_dependency 'rake',          '~> 0.9'
  s.add_development_dependency 'rspec',         '~> 3.0'
  s.add_development_dependency 'spork',         '~> 0.9'
  s.add_development_dependency 'test-kitchen',  '~> 1.2'
  s.add_development_dependency 'webmock',       '~> 1.11'
  s.add_development_dependency 'yard',          '~> 0.8'
end
