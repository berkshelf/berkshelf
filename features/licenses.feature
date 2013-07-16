Feature: Installing cookbooks with specific licenses
  As a user
  I want to ensure my company only uses cookbooks that fall in our legal realm
  So that I can safely install and legally use community cookbooks

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty
    And the cookbook store is empty

  Scenario: With licenses defined
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["mit"]
      }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      is not in your list of allowed licenses
      """

  Scenario: With a license that is not listed
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["apache2"]
      }
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      'mit' is not in your list of allowed licenses
      """

  Scenario: With raise_license_exception defined
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["mit"],
        "raise_license_exception": true
      }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      is not in your list of allowed licenses
      """

  Scenario: With a license that is not listed
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["apache2"],
        "raise_license_exception": true
      }
      """
    When I run `berks install`
    Then the output should contain:
      """
      'mit' is not in your list of allowed licenses
      """
    And the exit status should be "LicenseNotAllowed"

  Scenario: With a :path location
    Given the cookbook store has the cookbooks:
      | fake | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'fake', path: '../../tmp/berkshelf/cookbooks/fake-0.1.0'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["apache2"],
        "raise_license_exception": true
      }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      'mit' is not in your list of allowed licenses
      """
