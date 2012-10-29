# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require 'bundler'
require 'bundler/setup'

require 'berkshelf'
require 'thor/rake_compat'

class Default < Thor
  class Gem < Thor
    include Thor::RakeCompat
    Bundler::GemHelper.install_tasks

    namespace :gem

    desc "build", "Build berkshelf-#{Berkshelf::VERSION}.gem into the pkg directory"
    def build
      Rake::Task["build"].execute
    end

    desc "release", "Create tag v#{Berkshelf::VERSION} and build and push berkshelf-#{Berkshelf::VERSION}.gem to Rubygems"
    def release
      Rake::Task["release"].execute
    end

    desc "install", "Build and install berkshelf-#{Berkshelf::VERSION}.gem into system gems"
    def install
      Rake::Task["install"].execute
    end
  end

  class Spec < Thor
    include Thor::Actions

    namespace :spec
    default_task :all

    desc "all", "Run all tests"
    def all
      invoke(:unit)
      invoke(:acceptance)
    end

    desc "ci", "Run all possible tests on Travis-CI"
    def ci
      ENV['CI'] = 'true' # Travis-CI also sets this, but set it here for local testing
      run "rspec --tag ~chef_server --tag ~focus --color --format=documentation spec"
      run "cucumber --format pretty --tags ~@chef_server"
    end

    desc "unit", "Run unit tests"
    def unit
      run "rspec --color --format=documentation spec"
    end

    desc "acceptance", "Run acceptance tests"
    def acceptance
      run "cucumber --color --format pretty --tags ~@no_run"
    end
  end

  class VCR < Thor
    namespace :vcr
    default_task :clean

    desc "clean", "clean VCR cassettes"
    def clean
      FileUtils.rm_rf("spec/fixtures/vcr_cassettes")
    end
  end
end
