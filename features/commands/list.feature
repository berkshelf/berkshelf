Feature: berks list
  Scenario: When everything is good
    Given the cookbook store has the cookbooks:
      | fake1 | 1.0.0 |
      | fake2 | 1.0.1 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake1', '1.0.0'
      cookbook 'fake2', '1.0.1'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake1 (= 1.0.0)
        fake2 (= 1.0.1)

      GRAPH
        fake1 (1.0.0)
        fake2 (1.0.1)
      """
    When I successfully run `berks list`
    Then the output should contain:
      """
      Cookbooks installed by your Berksfile:
        * fake1 (1.0.0)
        * fake2 (1.0.1)
      """

  Scenario: When the lockfile is not present
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I run `berks list`
    Then the output should contain:
      """
      Lockfile not found! Run `berks install` to create the lockfile.
      """
    And the exit status should be "LockfileNotFound"

  Scenario: When a dependency is not in the lockfile
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES

      GRAPH
        not_fake (1.0.0)
      """
    When I run `berks list`
    Then the output should contain:
      """
      The lockfile is out of sync! Run `berks install` to sync the lockfile.
      """
    And the exit status should be "LockfileOutOfSync"

  Scenario: When a dependency is not installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I run `berks list`
    Then the output should contain:
      """
      The cookbook 'fake (1.0.0)' is not installed. Please run `berks install` to download and install the missing dependency.
      """
    And the exit status should be "DependencyNotInstalled"

  Scenario: When there are no dependencies
    Given I have a Berksfile pointing at the local Berkshelf API
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I successfully run `berks list`
    Then the output should contain:
      """
      There are no cookbooks installed by your Berksfile
      """
