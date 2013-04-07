Feature: info command
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: Running the info command with an installed cookbook name
    Given the cookbook store has the cookbooks:
      | mysql   | 2.1.2  |
      | mysql   | 1.2.4  |
      | mysql   | 0.10.0 |
    When I successfully run `berks info mysql`
    Then the output should contain "Name: mysql"
    Then the output should contain "Version: 2.1.2"
    Then the output should contain "Description: A fabulous new cookbook"
    Then the output should contain "Author: YOUR_COMPANY_NAME"
    Then the output should contain "Email: YOUR_EMAIL"
    Then the output should contain "License: none"
    And the exit status should be 0

  Scenario: Running the info command with an installed cookbook name and a version
    Given the cookbook store has the cookbooks:
      | mysql   | 2.1.2  |
      | mysql   | 1.2.4  |
      | mysql   | 0.10.0 |
    When I successfully run `berks info mysql --version 1.2.4`
    Then the output should contain "Name: mysql"
    Then the output should contain "Version: 1.2.4"
    Then the output should contain "Description: A fabulous new cookbook"
    Then the output should contain "Author: YOUR_COMPANY_NAME"
    Then the output should contain "Email: YOUR_EMAIL"
    Then the output should contain "License: none"
    And the exit status should be 0

  Scenario: Running the info command with a not installed cookbook name
    Given the cookbook store has the cookbooks:
      | mysql   | 2.1.2  |
    When I run `berks info build-essential`
    Then the output should contain "Cookbook 'build-essential' was not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
