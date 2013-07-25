Feature: Listing cookbooks defined by a Berksfile
  As a user with a Berksfile
  I want a way to show all my cookbooks and their versions without opening my Berksfile
  So that I can be more productive

  Scenario: Running the list command
    Given the cookbook store has the cookbooks:
      | fake1 | 1.0.0 |
      | fake2 | 1.0.1 |
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      cookbook 'fake2', '1.0.1'
      """
    When I successfully run `berks list`
    Then the output should contain:
      """
      Cookbooks installed by your Berksfile:
        * fake1 (1.0.0)
        * fake2 (1.0.1)
      """


  Scenario: Running the list command with no sources defined
    Given I have a Berksfile pointing at the local Berkshelf API
    When I successfully run `berks list`
    Then the output should contain:
      """
      There are no cookbooks installed by your Berksfile
      """
