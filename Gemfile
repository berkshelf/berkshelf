source "https://rubygems.org"

gemspec

group :changelog do
  gem "github_changelog_generator"
end

group :build do
  gem "rake",          ">= 10.1"
end

group :development do
  # these all deliberately float because berkshelf has a Gemfile.lock that
  # equality pins them.  temporarily pin as necessary for API breaks.
  gem "aruba",         ">= 0.10.0"
  gem "chef-zero",     ">= 4.0"
  gem "dep_selector",  ">= 1.0"
  gem "fuubar",        ">= 2.0"
  gem "rspec",         ">= 3.0"
  gem "rspec-its",     ">= 1.2"
  gem "webmock",       ">= 1.11"
  gem "yard",          ">= 0.8"
  gem "http",          ">= 0.9.8"
  gem "activesupport", "~> 4.0" # pinning for ruby 2.1.x
  gem "chefstyle"
end

group :test do
  gem "berkshelf-api", git: "https://github.com/berkshelf/berkshelf-api.git", ref: "9fb3d95779c4ff72b0074072105caaf70b978bf0"
end
