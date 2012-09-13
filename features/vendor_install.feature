Feature: install cookbooks to a given vendor path
  As a user of Berkshelf
  I want to be able to install cookbooks to a specific directory
  So I vendor my cookbooks and package them with my application

  Scenario: default
    Given I write to "Berksfile" with:
      """
      site :opscode

      cookbook "artifact", "0.10.0"
      """
    When I run the install command with flags:
      | --path vendor/cookbooks |
    Then the cookbook store should have the cookbooks:
      | artifact | 0.10.0 |
    Then the following directories should exist:
      | vendor/cookbooks          |
      | vendor/cookbooks/artifact |
    And the exit status should be 0
