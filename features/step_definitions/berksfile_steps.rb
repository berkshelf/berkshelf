Given /I have a Berksfile pointing at the community API endpoint with:/ do |content|
  steps %Q{
    Given a file named "Berksfile" with:
      """
      source '#{Berkshelf::Berksfile::DEFAULT_API_URL}'

      #{content}
      """
  }
end

Given /^I have a Berksfile pointing at the local Berkshelf API$/ do
  steps %Q{
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      """
  }
end

Given /^I have a Berksfile pointing at the local Berkshelf API with:$/ do |content|
  steps %Q{
    Given I have a Berksfile at "." pointing at the local Berkshelf API with:
      """
      #{content}
      """
  }
end

Given /^I have a Berksfile at "(.+)" pointing at the local Berkshelf API with:$/ do |path, content|
  steps %Q{
    Given a directory named "#{path}"
    And a file named "#{path}/Berksfile" with:
      """
      source 'http://0.0.0.0:#{BERKS_API_PORT}'

      #{content}
      """
  }
end

Given(/^I have a Berksfile\.lock set up to apply$/) do
  steps %Q{
    Given I have a Berksfile pointing at the local Berkshelf API
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And I successfully run `berks install`
  }
end
