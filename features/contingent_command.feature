Feature: contingent command
  As a user with a Berksfile
  I want a way to the cookbooks that depend on another
  So that I can better understand my infrastructure

  @slow_process
  Scenario: Running the contingent command against a cookbook
    Given I write to "Berksfile" with:
      """
      cookbook "database", "1.3.12"
      """
    And I successfully run `berks install`
    When I run `berks contingent mysql`
    Then the output should contain:
      """
      Cookbooks contingent upon mysql:
        * database (1.3.12)
      """
    And the exit status should be 0
