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
    And the Lockfile has:
      | bacon | 1.1.0 |
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
    And the Lockfile has:
      | bacon | 1.0.0 |
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
    And the Lockfile has:
      | bacon | 1.0.0 |
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      The following cookbooks have newer versions:
        * bacon (1.5.8)
      """

  Scenario: When there is no lockfile present
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '1.0.0'
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Could not find cookbook 'bacon'. Make sure it is in your Berksfile, then run `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "DependencyNotFound"

  Scenario: When the cookbook is not installed
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '1.0.0'
      """
    And the Lockfile has:
      | bacon | 1.0.0 |
    When I run `berks outdated`
    Then the output should contain:
      """
      Could not find cookbook 'bacon (1.0.0)'. Run `berks install` to download and install the missing cookbook.
      """
    And the exit status should be "CookbookNotFound"
