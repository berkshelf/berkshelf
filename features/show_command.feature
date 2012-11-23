Feature: show command
  As a user with a Berksfile
  I want a way to show the path to a cookbooks on my local file system
  So that I can view the source and debug

  Scenario: Running the show command with an installed cookbook name
    Given I write to "Berksfile" with:
      """
      cookbook "build-essential", "1.2.0"
      cookbook "chef-client", "1.2.0"
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    When I run `berks show build-essential`
    Then the output should contain "berkshelf/tmp/berkshelf/cookbooks/build-essential-1.2.0"
    And the exit status should be 0

  Scenario: Running the show command with a not installed cookbook name
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    When I run `berks show build-essential`
    Then the output should contain "Cookbook 'build-essential' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
