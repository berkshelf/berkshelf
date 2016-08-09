require "bundler/gem_tasks"

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
