Feature: install cookbooks to a given vendor path
  As a user of Berkshelf
  I want to be able to install cookbooks to a specific directory
  So I vendor my cookbooks and package them with my application

  Scenario: default
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I run the install command with flags:
      | --path vendor/cookbooks |
    Then the following directories should exist:
      | vendor/cookbooks          |
      | vendor/cookbooks/fake |
    And the exit status should be 0
