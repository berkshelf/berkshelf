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
      source 'http://127.0.0.1:#{BERKS_API_PORT}'

      #{content}
      """
  }
end

Given /I have a Berksfile pointing at an( authenticated)? Artifactory server with:/ do |authenticated, content|
  if ENV["TEST_BERKSHELF_ARTIFACTORY"]
    steps %Q{
      Given a file named "Berksfile" with:
        """
        source artifactory: '#{ENV['TEST_BERKSHELF_ARTIFACTORY']}'#{authenticated ? ", api_key: '#{ENV['TEST_BERKSHELF_ARTIFACTORY_API_KEY']}'" : ''}

        #{content}
        """
    }
  else
    skip_this_scenario
  end
end
