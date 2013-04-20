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
      unless run_unit && run_acceptance && run_quality
        exit 1
      end
    end

    desc "ci", "Run all possible tests on Travis-CI"
    def ci
      ENV['CI'] = 'true' # Travis-CI also sets this, but set it here for local testing
      unless run_unit("--tag ~chef_server") && run_acceptance("--tags ~@chef_server") && run_quality
        exit 1
      end
    end

    desc "unit", "Run unit tests"
    def unit
      unless run_unit
        exit 1
      end
    end

    desc "acceptance", "Run acceptance tests"
    def acceptance
      unless run_acceptance
        exit 1
      end
    end

    desc "quality", "Run quality tests"
    def quality
      unless run_quality
        exit 1
      end
    end

    no_tasks do
      def run_unit(*flags)
        run "rspec --color --format=documentation #{flags.join(' ')} spec"
      end

      def run_acceptance(*flags)
        run "cucumber --color --format pretty --tags ~@no_run #{flags.join(' ')}"
      end

      def run_quality
        run "cane --gte coverage/.last_run.json,90"
      end
    end
  end
end
