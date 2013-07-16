Feature: Vendoring cookbooks to a directory
  As a CLI user
  I want a command to vendor cookbooks into a directory
  So they are structured similar to a Chef Repository

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty

  Scenario: successfully vendoring a Berksfile with multiple cookbook demands
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf'
      cookbook 'elixir'
      """
    And the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
      | elixir    | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks vendor cukebooks`
    Then the output should contain:
      """
      Vendoring berkshelf (1.0.0) to
      """
    And the output should contain:
      """
      Vendoring elixir (1.0.0) to
      """
    And a directory named "cukebooks/berkshelf" should exist
    And a directory named "cukebooks/elixir" should exist
    And the directory "cukebooks/berkshelf" should contain version "1.0.0" of the "berkshelf" cookbook
    And the directory "cukebooks/elixir" should contain version "1.0.0" of the "elixir" cookbook

  Scenario: attempting to vendor when no Berksfile is present
    When I run `berks vendor cukebooks`
    Then the exit status should be "BerksfileNotFound"

  Scenario: vendoring a Berksfile with a metadata demand
    Given a cookbook named "sparkle-motion"
    And the cookbook "sparkle-motion" has the file "Berksfile" with:
      """
      source "http://localhost:26210"

      metadata
      """
    When I cd to "sparkle-motion"
    And I successfully run `berks vendor cukebooks`
    Then the output should contain:
      """
      Vendoring sparkle-motion (0.0.0) to
      """
    And a directory named "cukebooks/sparkle-motion" should exist
    And the directory "cukebooks/sparkle-motion" should contain version "0.0.0" of the "sparkle-motion" cookbook
