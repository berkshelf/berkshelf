@api_server
Feature: berks package
  Background:
    * the cookbook store has the cookbooks:
      | fake | 1.0.0 |

  Scenario: When no options are passed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 1.0.0'
      """
    When I successfully run `berks package my-cookbooks.tar.gz`
    Then a file named "my-cookbooks.tar.gz" should exist
    And the output should contain:
      """
      Cookbook(s) packaged to
      """
