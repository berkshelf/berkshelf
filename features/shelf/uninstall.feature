Feature: Removing a cookbook from the Berkshelf shelf
  As a user with a cookbook store
  I want to remove a cookbook because it's a bad version
  So that I don't have to manually touch things in the ~/.berkshelf directory

  Scenario: With no cookbooks in the store
    When I run `berks shelf uninstall fake`
    Then the output should contain:
      """
      Cookbook 'fake' is not in the Berkshelf shelf
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: With two cookbooks in the store
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.3.4 |
    When I successfully run `berks shelf uninstall fake`
    Then the output should contain:
      """
      Successfully uninstalled fake (1.0.0)
      """
    And the cookbook store should not have the cookbooks:
      | fake | 1.0.0 |
    And the cookbook store should have the cookbooks:
      | ekaf | 2.3.4 |
    And the exit status should be 0


  Scenario: With multiple cookbook versions installed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    When I successfully run `berks shelf uninstall fake`
    Then the output should contain:
      """
      Successfully uninstalled fake (1.0.0)
      Successfully uninstalled fake (1.1.0)
      Successfully uninstalled fake (1.2.0)
      Successfully uninstalled fake (2.0.0)
      """
    And the cookbook store should not have the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    And the exit status should be 0

  Scenario: When specifying a version
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    When I successfully run `berks shelf uninstall fake --version 1.0.0`
    Then the output should contain:
      """
      Successfully uninstalled fake (1.0.0)
      """
    And the cookbook store should not have the cookbooks:
      | fake | 1.0.0 |
    And the cookbook store should have the cookbooks:
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    And the exit status should be 0

  Scenario: With contingencies
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | ekaf | 2.3.4 |
    And the cookbook store has the cookbooks:
      | ekaf | 2.3.4 |
    When I run `berks shelf uninstall ekaf` interactively
    And I type "yes"
    Then the output should contain:
      """
      [fake (1.0.0)] depend on ekaf.

      Are you sure you want to continue? (y/N)
      """
    And the output should contain:
      """
      Successfully uninstalled ekaf (2.3.4)
      """
    And the cookbook store should not have the cookbooks:
      | ekaf | 2.3.4 |
    And the exit status should be 0

  Scenario: With contingencies and the --force flag
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | ekaf | 2.3.4 |
    And the cookbook store has the cookbooks:
      | ekaf | 2.3.4 |
    When I run `berks shelf uninstall ekaf --force`
    Then the output should contain:
      """
      Successfully uninstalled ekaf (2.3.4)
      """
    And the cookbook store should not have the cookbooks:
      | ekaf | 2.3.4 |
    And the exit status should be 0
