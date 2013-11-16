require 'bundler/gem_tasks'

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = [
    '--color',
    '--format progress',
  ].join(' ')
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:acceptance) do |t|
  t.cucumber_opts = [
    '--color',
    '--format progress',
    '--strict',
    '--tags ~@no_run',
  ].join(' ')
end

desc 'Run all tests'
task test: [:unit, :acceptance]

task default: [:test]
