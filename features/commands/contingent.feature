Feature: berks contingent
  Background:
    * the Berkshelf API server's cache is empty
    * the Chef Server is empty
    * the cookbook store is empty

  Scenario: When there are dependent cookbooks
    Given the cookbook store has the cookbooks:
      | dep | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And the cookbook store contains a cookbook "ekaf" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '1.0.0'
      """
    And I run `berks install`
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      Cookbooks in this Berksfile contingent upon 'dep':
        * ekaf (1.0.0)
        * fake (1.0.0)
      """

  Scenario: When there are no dependent cookbooks
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And I run `berks install`
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      There are no cookbooks in this Berksfile contingent upon 'dep'.
      """

  Scenario: When the cookbook is not in the Berksfile
    Given I have a Berksfile pointing at the local Berkshelf API
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      There are no cookbooks in this Berksfile contingent upon 'dep'.
      """
