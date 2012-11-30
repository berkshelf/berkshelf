Feature: outdated command
  As a user
  I want to know what cookbooks are outdated before I run update
  So that I can decide whether to update everything at once

  Scenario: Running berks outdated with no version constraints
    Given I write to "Berksfile" with:
      """
      cookbook "artifact"
      cookbook "build-essential"
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      All cookbooks up to date
      """

  Scenario: Running berks outdated with satisfied version constraints
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", ">= 0.11.0"
      cookbook "build-essential", ">= 1.0.0"
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      All cookbooks up to date
      """

  Scenario: Running berks outdated with unsatisfied version constraints
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "~> 0.9.0"
      cookbook "build-essential", "~> 0.7.0"
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      Cookbook 'artifact (~> 0.9.0)' is outdated
      """
    And the output should contain:
      """
      Cookbook 'build-essential (~> 0.7.0)' is outdated
      """
