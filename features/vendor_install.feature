Feature: install cookbooks to a given vendor path
  As a user of Berkshelf
  I want to be able to install cookbooks to a specific directory
  So I vendor my cookbooks and package them with my application

  Scenario: default
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install --path vendor/cookbooks`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    Then the following directories should exist:
      | vendor/cookbooks          |
      | vendor/cookbooks/berkshelf-cookbook-fixture |
    And the exit status should be 0

  Scenario: default
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install --vendor`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    Then the following directories should exist:
      | vendor/cookbooks          |
      | vendor/cookbooks/berkshelf-cookbook-fixture |
    And the exit status should be 0
