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
      Cookbooks contingent upon hostsfile:
        * berkshelf-cookbook-fixture (1.0.0)
      """
    And the exit status should be 0
