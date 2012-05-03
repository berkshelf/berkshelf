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
  r.main = "README.md"
  r.rdoc_files.include("README.md", "lib/**/*.rb")
  r.rdoc_dir = "rdoc"
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :check => [:default, "rdoc:check"]
task :default => [:clean, :spec]
