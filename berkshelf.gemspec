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

  s.description               = %q{Manages a Chef cookbook's dependencies}
  s.summary                   = s.description
  s.homepage                  = "https://docs.chef.io/berkshelf.html"
  s.license                   = "Apache-2.0"
  s.files                     = %w{LICENSE Gemfile Rakefile} + Dir.glob("*.gemspec") + Dir.glob("{lib,spec, features}/**/*")
  s.executables               = Dir.glob("bin/**/*").map { |f| File.basename(f) }
  s.name                      = "berkshelf"
  s.require_paths             = ["lib"]
  s.version                   = Berkshelf::VERSION
  s.required_ruby_version     = ">= 2.4.0"
  s.required_rubygems_version = ">= 2.0.0"

  s.add_dependency "mixlib-shellout",      ">= 2.0", "< 4.0"
  s.add_dependency "cleanroom",            "~> 1.0"
  s.add_dependency "minitar",              ">= 0.6"
  s.add_dependency "retryable",            ">= 2.0", "< 4.0"
  s.add_dependency "solve",                "~> 4.0"
  s.add_dependency "thor",                 ">= 0.20"
  s.add_dependency "octokit",              "~> 4.0"
  s.add_dependency "mixlib-archive",       ">= 0.4", "< 2.0"
  s.add_dependency "concurrent-ruby",      "~> 1.0"
  s.add_dependency "chef",                 ">= 13.6.52"
  s.add_dependency "chef-config"
  # this is required for Mixlib::Config#from_json
  s.add_dependency "mixlib-config", ">= 2.2.5"
end
