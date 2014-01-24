Feature: Installing cookbooks with specific licenses
  Background:
    * the Berkshelf API server's cache is empty
    * the Chef Server is empty
    * the cookbook store is empty
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """

  Scenario: when licenses is defined
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 | mit |
    And I have a Berkshelf config file containing:
      """
      { "allowed_licenses": ["mit"] }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      is not in your list of allowed licenses
      """

  Scenario: when a license is not listed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 | mit |
    And I have a Berkshelf config file containing:
      """
      { "allowed_licenses": ["apache2"] }
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      'mit' is not in your list of allowed licenses
      """

  Scenario: when raise_license_exception is defined
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 | mit |
    And I have a Berkshelf config file containing:
      """
      { "allowed_licenses": ["mit"], "raise_license_exception": true }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      is not in your list of allowed licenses
      """

  Scenario: when raise_license_exception is defined and a license is not listed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 | mit |
    And I have a Berkshelf config file containing:
      """
      { "allowed_licenses": ["apache2"], "raise_license_exception": true }
      """
    When I run `berks install`
    Then the output should contain:
      """
      'mit' is not in your list of allowed licenses
      """
    And the exit status should be "LicenseNotAllowed"

  Scenario: when the cookbook is a path location
    Given the cookbook store has the cookbooks:
      | fake | 0.1.0 | mit |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', path: '../../tmp/berkshelf/cookbooks/fake-0.1.0'
      """
    And I have a Berkshelf config file containing:
      """
      { "allowed_licenses": ["apache2"], "raise_license_exception": true }
      """
    When I successfully run `berks install`
    Then the output should not contain:
      """
      'mit' is not in your list of allowed licenses
      """
