Feature: resolve cookbooks
  As a Berkshelf user
  I want to see the resolver in action
  So I can debug any issues that arise

  Background:
    * the Berkshelf API server's cache is empty
    * the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
      | berkshelf | 2.0.0 |
    * the Berkshelf API server's cache is up to date
    * I write to "Berksfile" with:
      """
      source "http://localhost:26210"
      cookbook 'berkshelf'
      """

  Scenario: with DEBUG_RESOLVER=1
    Given the environment variable DEBUG_RESOLVER is "1"
    When I successfully run `berks install`
    Then the output should contain:
      """
      Attempting to find a solution
      Adding constraint berkshelf >= 0.0.0 from root
      """

  Scenario: without DEBUG_RESOLVER
    Given the environment variable DEBUG_RESOLVER is nil
    When I successfully run `berks install`
    Then the output should not contain:
      """
      Attempting to find a solution
      """
