Feature: Applying cookbook versions to a Chef Environment
  As a berks user
  I want to push my berks resolved cookbook versions to my environment
  So that I can avoid manual configuration of my environments

  @chef_server
  Scenario: Locking a cookbook version with dependencies
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dependency | 2.0.0 |
    And the cookbook store has the cookbooks:
      | dependency | 2.0.0 |
    And I have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks apply berkshelf_lock_test`
    Then the version locks in "berkshelf_lock_test" should be:
      | cookbook   | version_lock |
      | fake       | = 1.0.0 |
      | dependency | = 2.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: Locking cookbook versions to a non-existent Chef Environment
    Given I do not have an environment named "berkshelf_lock_test"
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I run the apply command on "berkshelf_lock_test"
    Then the output should contain:
      """
      The environment 'berkshelf_lock_test' does not exist
      """
    And the CLI should exit with the status code for error "EnvironmentNotFound"
