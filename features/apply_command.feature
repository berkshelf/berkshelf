Feature: Apply cookbook versions to a Chef Environment
  As a berks user
  I want to push my berks resolved cookbook versions to my environment
  So that I can avoid manual configuration of my environments

  @chef_server
  Scenario: Locking a cookbook version with dependencies
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
      | hostsfile                  | 1.0.1 |
    Given I have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'deps'
      """
    When I successfully run `berks apply berkshelf_lock_test`
    Then the version locks in "berkshelf_lock_test" should be:
    | cookbook                     | version_lock |
    | berkshelf-cookbook-fixture   |        1.0.0 |
    | hostsfile                    |        1.0.1 |
    And the exit status should be 0

  @chef_server
  Scenario: Locking cookbook versions to a non-existent Chef Environment
    Given I do not have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I run the apply command on "berkshelf_lock_test"
    Then the output should contain:
      """
      The environment "berkshelf_lock_test" does not exist.
      """
    And the CLI should exit with the status code for error "EnvironmentNotFound"
