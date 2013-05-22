Feature: contingent command
  As a user with a Berksfile
  I want a way to the cookbooks that depend on another
  So that I can better understand my infrastructure

  @slow_process
  Scenario: Running the contingent command against a cookbook
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'deps'
      """
    And I successfully run `berks contingent hostsfile`
    Then the output should contain:
      """
      Cookbooks in this Berksfile contingent upon hostsfile:
        * berkshelf-cookbook-fixture (1.0.0)
      """
    And the exit status should be 0

  @slow_process
  Scenario: Running the contingent command against a cookbook that isn't in the Berksfile
    Given an empty file named "Berksfile"
    And I successfully run `berks contingent non-existent`
    Then the output should contain:
      """
      There are no cookbooks contingent upon 'non-existent' defined in this Berksfile
      """
