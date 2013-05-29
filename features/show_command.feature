Feature: Showing the path to a cookbook defined by a Berksfile
  As a user with a Berksfile
  I want a way to show the path to a cookbooks on my local file system
  So that I can view the source and debug

  Scenario: With an installed cookbook name
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks show fake`
    Then the output should contain "berkshelf/tmp/berkshelf/cookbooks/fake-1.0.0"
    And the exit status should be 0

  Scenario: When the cookbook is not installed
    Given an empty file named "Berksfile"
    When I run `berks show fake`
    Then the output should contain "Cookbook 'fake' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
