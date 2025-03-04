require File.expand_path("lib/berkshelf/version", __dir__)

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
  s.required_ruby_version     = ">= 2.7.0"
  s.required_rubygems_version = ">= 2.0.0"
  s.metadata                  = {
    "bug_tracker_uri" => "https://github.com/chef/berkshelf/issues",
    "source_code_uri" => "https://github.com/chef/berkshelf",
    "changelog_uri"   => "https://github.com/chef/berkshelf/blob/main/CHANGELOG.md",
  }

  ruby_version = Gem::Version.new(RUBY_VERSION)

  s.add_dependency "mixlib-shellout",      ">= 2.0", "< 4.0"

  # Reverted because of https://github.com/chef/berkshelf/issues/56
  s.add_dependency "cleanroom",            "~> 1.0"

  if ruby_version >= Gem::Version.new("3.1.0")
    s.add_dependency "minitar",              "~> 1.0"
    s.add_dependency "chef",                 ">= 18.0.0"
  else
    s.add_dependency "minitar",              "~> 0.12"

    if ruby_version >= Gem::Version.new("3.0.0")
      s.add_dependency "chef",                 "~> 17.0" # needed for --skip-syntax-check
    else
      s.add_dependency "chef",                 ">= 15.7.32"
    end
  end

  s.add_dependency "retryable",            ">= 2.0", "< 4.0"
  s.add_dependency "solve",                "~> 4.0"

  s.add_dependency "thor",                 ">= 0.20", "< 1.3.0"
  s.add_dependency "octokit",              ">= 4.0", "< 6.0"

  s.add_dependency "mixlib-archive",       ">= 1.1.4", "< 2.0" # needed for ruby 3.0 / Dir.chdir removal
  s.add_dependency "concurrent-ruby",      "~> 1.0"

  s.add_dependency "ffi",                "~> 1.9", "< 1.16.0" #

  s.add_dependency "chef-config"
  # this is required for Mixlib::Config#from_json
  s.add_dependency "mixlib-config", ">= 2.2.5"
end
