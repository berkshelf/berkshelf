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
    Then the output should contain exactly ""

  Scenario: Running berks outdated with satisfied version constraints
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", ">= 0.11.0"
      cookbook "build-essential", ">= 1.0.0"
      """
    When I run `berks outdated`
    Then the output should contain exactly ""

  Scenario: Running berks outdated with unsatisfied version constraints
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "~> 0.9.0"
      cookbook "build-essential", "~> 0.7.0"
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Local cookbook 'artifact (~> 0.9.0)' is outdated (0.11.1)
      Local cookbook 'build-essential (~> 0.7.0)' is outdated (1.2.0)
      """
