Feature: info command
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: Running the info command with an installed cookbook name
    Given I write to "Berksfile" with:
      """
      cookbook "build-essential", "1.2.0"
      cookbook "chef-client", "1.2.0"
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    When I run `berks info build-essential`
    Then the output should contain "Name: build-essential"
    Then the output should contain "Version: 1.2.0"
    Then the output should contain "Description: Installs C compiler / build tools"
    Then the output should contain "Author: Opscode, Inc."
    Then the output should contain "Email: cookbooks@opscode.com"
    Then the output should contain "License: Apache 2.0"
    And the exit status should be 0

  Scenario: Running the info command with a not installed cookbook name
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    When I run `berks info build-essential`
    Then the output should contain "Cookbook 'build-essential' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
