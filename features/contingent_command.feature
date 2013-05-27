Feature: Running the contingent command
  As a user with a Berksfile
  I want a way to the cookbooks that depend on another
  So that I can better understand my infrastructure

  Scenario: When there are dependent cookbooks
    Given the cookbook store has the cookbooks:
      | dep | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And the cookbook store contains a cookbook "ekaf" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '1.0.0'
      """
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      Cookbooks in this Berksfile contingent upon dep:
        * ekaf (1.0.0)
        * fake (1.0.0)
      """
    And the exit status should be 0

  Scenario: When there are no dependent cookbooks
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      There are no cookbooks contingent upon 'dep' defined in this Berksfile
      """
    And the exit status should be 0

  Scenario: When the cookbook is not in the Berksfile
    Given an empty file named "Berksfile"
    And I successfully run `berks contingent dep`
    Then the output should contain:
      """
      There are no cookbooks contingent upon 'dep' defined in this Berksfile
      """
