Feature: info command
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: Running the info command with an installed cookbook name
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0  |
      | berkshelf-cookbook-fixture   | 0.2.0  |
      | berkshelf-cookbook-fixture   | 0.1.0  |
    When I successfully run `berks info berkshelf-cookbook-fixture`
    Then the output should contain "Name: berkshelf-cookbook-fixture"
    Then the output should contain "Version: 1.0.0"
    Then the output should contain "Description: A fabulous new cookbook"
    Then the output should contain "Author: YOUR_COMPANY_NAME"
    Then the output should contain "Email: YOUR_EMAIL"
    Then the output should contain "License: none"
    And the exit status should be 0

  Scenario: Running the info command with an installed cookbook name and a version
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0  |
      | berkshelf-cookbook-fixture   | 0.2.0  |
      | berkshelf-cookbook-fixture   | 0.1.0  |
    When I successfully run `berks info berkshelf-cookbook-fixture --version 0.2.0`
    Then the output should contain "Name: berkshelf-cookbook-fixture"
    Then the output should contain "Version: 0.2.0"
    Then the output should contain "Description: A fabulous new cookbook"
    Then the output should contain "Author: YOUR_COMPANY_NAME"
    Then the output should contain "Email: YOUR_EMAIL"
    Then the output should contain "License: none"
    And the exit status should be 0

  Scenario: Running the info command with a not installed cookbook name
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0  |
    When I run `berks info build-essential`
    Then the output should contain "Cookbook 'build-essential' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
