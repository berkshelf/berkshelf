# encoding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
require 'thor/rake_compat'

class Gem < Thor
  include Thor::RakeCompat
  Bundler::GemHelper.install_tasks

  desc 'build', "Build berkshelf-#{Berkshelf::VERSION}.gem into the pkg directory"
  def build
    Rake::Task['build'].execute
  end

  desc 'install', "Build and install berkshelf-#{Berkshelf::VERSION}.gem into system gems"
  def install
    Rake::Task['install'].execute
  end

  desc 'release', "Create tag v#{Berkshelf::VERSION} and build and push berkshelf-#{Berkshelf::VERSION}.gem to Rubygems"
  def release
    Rake::Task['release'].execute
  end
end

class Spec < Thor
  include Thor::Actions
  default_task :all

  desc 'all', 'Run all specs and features'
  def all
    exit(units_command && acceptance_command && quality_command)
  end

  desc 'ci', 'Run tests on Travis'
  def ci
    ENV['CI'] = 'true' # Travis-CI also sets this, but set it here for local testing
    all
  end

  desc 'unit', 'Run unit tests'
  def unit
    exit(units_command)
  end

  desc 'acceptance', 'Run acceptance tests'
  def acceptance
    exit(acceptance_command)
  end

  desc 'quality', 'Run code quality tests'
  def quality
    exit(quality_command)
  end

  no_tasks do
    def units_command
      run('rspec --color --format=documentation spec/unit')
    end

    def acceptance_command
      run('cucumber --color --format pretty --tags ~@no_run')
    end

    def quality_command
      run('cane --gte coverage/.last_run.json,90')
    end
  end
end
