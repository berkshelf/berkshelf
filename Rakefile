require "bundler/gem_tasks"
require 'rdoc/task'
require 'rspec/core/rake_task'

desc "check documentation coverage"
task "rdoc:check" do 
  sh "rdoc -C " + Dir["lib/**/*.rb"].join(" ")
end

desc "clean up doco/coverage"
task :clean do
  sh "rm -fr rdoc coverage"
end

desc "generate documentation"
RDoc::Task.new :rdoc do |r|
  r.main = "README.rdoc"
  r.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  r.rdoc_dir = "rdoc"
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :check => [:default, "rdoc:check"]
task :default => [:clean, :spec]

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec) do |r|
    r.rspec_path = "bundle exec rspec"
  end
rescue LoadError
  desc 'RSpec rake task not available'
  task :spec do
    abort 'RSpec rake task is not available. Be sure to install rspec.'
  end
end

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format progress --tags ~@wip --tags ~@live"
  end

  namespace :features do
    Cucumber::Rake::Task.new(:wip) do |t|
      t.cucumber_opts = "--format progress --tags @wip"
    end

    Cucumber::Rake::Task.new(:current) do |t|
      t.cucumber_opts = "--format progress --tags @current"
    end

    Cucumber::Rake::Task.new(:tag) do |t|
      t.cucumber_opts = "--format progress --tags @#{ENV['tag']}"
    end
  end       
rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber.'
  end
end
