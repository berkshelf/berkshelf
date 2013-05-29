Feature: Listing all cookbooks in the Berkshelf shelf
  As a user with a cookbook store
  I want to show all the cookbooks I have installed
  So that I can be well informed

  Scenario: With no cookbooks in the store
    When I successfully run `berks shelf list`
    Then the output should contain:
      """
      There are no cookbooks in the Berkshelf shelf
      """
    And the exit status should be 0

  Scenario: With two cookbooks in the store
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.3.4 |
    When I successfully run `berks shelf list`
    Then the output should contain:
      """
      Cookbooks in the Berkshelf shelf:
        * ekaf (2.3.4)
        * fake (1.0.0)
      """
    And the exit status should be 0

  Scenario: With multiple cookbook versions installed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    When I successfully run `berks shelf list`
    Then the output should contain:
      """
      Cookbooks in the Berkshelf shelf:
        * fake (1.0.0, 1.1.0, 1.2.0, 2.0.0)
      """
    And the exit status should be 0
