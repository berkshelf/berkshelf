# -*- encoding: utf-8; mode: ruby -*-
require File.expand_path("../lib/berkshelf/version", __FILE__)

Gem::Specification.new do |s|
  s.authors = [
    "Jamie Winsor",
    "Josiah Kiehl",
    "Michael Ivey",
    "Justin Campbell",
    "Seth Vargo",
  ]
  s.email = [
    "jamie@vialstudios.com",
    "jkiehl@riotgames.com",
    "michael.ivey@riotgames.com",
    "justin@justincampbell.me",
    "sethvargo@gmail.com",
  ]

  s.description               = %q{Manages a Cookbook's, or an Application's, Cookbook dependencies}
  s.summary                   = s.description
  s.homepage                  = "https://github.com/berkshelf/berkshelf"
  s.license                   = "Apache 2.0"
  s.files                     = `git ls-files`.split($\)
  s.executables               = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files                = s.files.grep(%r{^(test|spec|features)/})
  s.name                      = "berkshelf"
  s.require_paths             = ["lib"]
  s.version                   = Berkshelf::VERSION
  s.required_ruby_version     = ">= 2.4.0"
  s.required_rubygems_version = ">= 2.0.0"

  s.metadata.bug_tracker_uri   "https://github.com/berkshelf/berkshelf/issues"
  s.metadata.documentation_uri "https://docs.chef.io/berkshelf.html"
  s.metadata.homepage_uri      "https://github.com/berkshelf/berkshelf"
  s.metadata.mailing_list_uri  "https://discourse.chef.io"
  s.metadata.source_code_uri   "https://github.com/berkshelf/berkshelf"


  s.add_dependency "mixlib-shellout",      "~> 2.0"
  s.add_dependency "cleanroom",            "~> 1.0"
  s.add_dependency "minitar",              ">= 0.6"
  s.add_dependency "retryable",            "~> 2.0"
  s.add_dependency "solve",                "~> 4.0"
  s.add_dependency "thor",                 ">= 0.20"
  s.add_dependency "octokit",              "~> 4.0"
  s.add_dependency "mixlib-archive",       "~> 0.4"
  s.add_dependency "concurrent-ruby",      "~> 1.0"
  s.add_dependency "chef",                 ">= 13.6.52"
  s.add_dependency "chef-config"
  # this is required for Mixlib::Config#from_json
  s.add_dependency "mixlib-config", ">= 2.2.5"
end
