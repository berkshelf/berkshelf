Feature: Vendoring cookbooks to a specific path
  As a user of Berkshelf
  I want to be able to install cookbooks to a specific directory
  So I vendor my cookbooks and package them with my application

  Scenario: With a path option
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '1.0.0'
      """
    When I run the install command with flags:
      | --path vendor/cookbooks |
    Then the following directories should exist:
      | vendor/cookbooks          |
      | vendor/cookbooks/fake |
    And the exit status should be 0
