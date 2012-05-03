require "bundler/gem_tasks"
require 'rdoc/task'

task "rdoc:check" do 
  sh "rdoc -C " + Dir["lib/**/*.rb"].join(" ")
end

task :clean do
  sh "rm -fr rdoc coverage"
end

RDoc::Task.new :rdoc do |r|
  r.main = "README.rdoc"
  r.rdoc_files.include("README.md", "lib/**/*.rb")
  r.rdoc_dir = "rdoc"
end

task :check => [:default, "rdoc:check"]
task :default => [:clean, :spec]
