Given /^the gem "(.*)" is not installed$/ do |gem_name|
  allow(Gem::Specification).to receive(:find_by_name)
    .with(gem_name)
    .and_raise(Gem::LoadError)
end

Then /^the output should contain a warning to suggest supporting the option "(.*?)" by installing "(.*?)"$/ do |option, gem_name|
  step "the output should contain \"This cookbook was generated with --#{option}, however, #{gem_name} is not installed.\nTo make use of --#{option}: gem install #{gem_name}\""
end

Then /^the output should contain a warning to suggest supporting the default for "(.*?)" by installing "(.*?)"$/ do |option, gem_name|
  step "the output should contain \"By default, this cookbook was generated to support #{gem_name}, however, #{gem_name} is not installed.\nTo skip support for #{gem_name}, use --no-#{option}\"\nTo install #{gem_name}: gem install #{gem_name}"
end
