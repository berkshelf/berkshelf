Feature: show command
  As a user with a Berksfile
  I want a way to show the path to a cookbooks on my local file system
  So that I can view the source and debug

  Scenario: Running the show command with an installed cookbook name
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks show fake`
    Then the output should contain "berkshelf/tmp/berkshelf/cookbooks/fake-1.0.0"
    And the exit status should be 0

  Scenario: Running the show command with a not installed cookbook name
    Given an empty file named "Berksfile"
    When I run `berks show build-essential`
    Then the output should contain "Cookbook 'build-essential' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
