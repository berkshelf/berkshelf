@api_server
Feature: berks apply
  Scenario: Locking a cookbook version with dependencies
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dependency | 2.0.0 |
    And the cookbook store has the cookbooks:
      | dependency | 2.0.0 |
    And the Chef Server has an environment named "my_env"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    And I successfully run `berks apply my_env`
    Then the version locks in the "my_env" environment should be:
      | fake       | = 1.0.0 |
      | dependency | = 2.0.0 |

  Scenario: Locking cookbook versions to a non-existent Chef Environment
    Given the Chef Server does not have an environment named "my_env"
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    And I run `berks apply my_env`
    Then the output should contain:
      """
      The environment 'my_env' does not exist
      """
    And the exit status should be "EnvironmentNotFound"

  Scenario: Locking an environment when no lockfile is present
    When I run `berks apply my_env`
    Then the output should contain:
      """
      Lockfile not found! Run `berks install` to create the lockfile.
      """
    And the exit status should be "LockfileNotFound"
