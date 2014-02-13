Feature: berks outdated
  Scenario: the dependency is up to date
    Given the Chef Server has cookbooks:
      | bacon | 1.0.0 |
      | bacon | 1.1.0 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.1.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '~> 1.1.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon (~> 1.1.0)

      GRAPH
        bacon (1.1.0)
      """

    When I successfully run `berks outdated`
    Then the output should contain:
      """
      All cookbooks up to date!
      """

  Scenario: the dependency has no version constraint and there are new items
    Given the Chef Server has cookbooks:
      | bacon | 1.0.0 |
      | bacon | 1.1.0 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon

      GRAPH
        bacon (1.0.0)
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      The following cookbooks have newer versions:
        * bacon (1.1.0)
      """

  Scenario: the dependency has a version constraint and there are new items that satisfy it
    Given the Chef Server has cookbooks:
      | bacon | 1.1.0 |
      | bacon | 1.2.1 |
      | bacon | 1.5.8 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '~> 1.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon (~> 1.0)

      GRAPH
        bacon (1.0.0)
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      The following cookbooks have newer versions:
        * bacon (1.5.8)
      """

  Scenario: When the lockfile is not present
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '1.0.0'
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Lockfile not found! Run `berks install` to create the lockfile.
      """
    And the exit status should be "LockfileNotFound"

  Scenario: When a dependency is not in the lockfile
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES

      GRAPH
        not_fake (1.0.0)
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      The lockfile is out of sync! Run `berks install` to sync the lockfile.
      """
    And the exit status should be "LockfileOutOfSync"

  Scenario: When a dependency is not installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon (= 1.0.0)

      GRAPH
        bacon (1.0.0)
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      The cookbook 'bacon (1.0.0)' is not installed. Please run `berks install` to download and install the missing dependency.
      """
    And the exit status should be "DependencyNotInstalled"
