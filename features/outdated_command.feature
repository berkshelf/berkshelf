Feature: Displaying outdated cookbooks
  As a user
  I want to know what cookbooks are outdated before I run update
  So that I can decide whether to update everything at once

  Scenario: the dependency is up to date
    Given the Chef Server has cookbooks:
      | bacon | 1.0.0 |
      | bacon | 1.1.0 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.1.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'bacon', '~> 1.1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "bacon": {
            "locked_version": "1.1.0"
          }
        }
      }
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      All cookbooks up to date!
      """

  Scenario: the dependency has a no version constraint and there are new items
    Given the Chef Server has cookbooks:
      | bacon | 1.0.0 |
      | bacon | 1.1.0 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'bacon'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "bacon": {
            "locked_version": "1.0.0"
          }
        }
      }
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      The following cookbooks have newer versions:
        * bacon (1.1.0) [http://localhost:26210]
      """

  Scenario: the dependency has a version constraint and there are new items that satisfy it
    Given the Chef Server has cookbooks:
      | bacon | 1.1.0 |
      | bacon | 1.2.1 |
      | bacon | 1.5.8 |
    And the Berkshelf API server's cache is up to date
    And the cookbook store has the cookbooks:
      | bacon | 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'bacon', '~> 1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "bacon": {
            "locked_version": "1.0.0"
          }
        }
      }
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      The following cookbooks have newer versions:
        * bacon (1.5.8) [http://localhost:26210]
      """
