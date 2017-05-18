require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "Rspec not available"
  task :spec
end

WINDOWS_PLATFORM = /mswin|win32|mingw/ unless defined? WINDOWS_PLATFORM

begin
  require "cucumber"
  require "cucumber/rake/task"
  Cucumber::Rake::Task.new(:features) do |t|
    if RUBY_PLATFORM =~ WINDOWS_PLATFORM
      t.cucumber_opts = "--tags ~@not-windows"
    end
  end
rescue LoadError
  task :features
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = Berkshelf::VERSION
    config.issues = false
    config.enhancement_labels = "enhancement,Enhancement,New Feature,Feature".split(",")
    config.bug_labels = "bug,Bug,Improvement".split(",")
    config.exclude_labels = "duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question,Upstream Bug,Discussion".split(",")
  end
rescue LoadError
end

task default: [:spec, :features]
task :ci do
  ENV["CI"] = "true"
  Rake::Task[:spec].invoke
  Rake::Task[:features].invoke
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle/rubocop is not available.  gem install chefstyle to do style checking."
end
