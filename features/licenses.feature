Feature: Installing cookbooks with specific licenses
  As a user
  I want to ensure my company only uses cookbooks that fall in our legal realm
  So that I can safely install and legally use community cookbooks

  Scenario: With licenses defined
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      site :opscode
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
    And the exit status should be 0

  Scenario: With a license that is not listed
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      site :opscode
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
    And the exit status should be 0

  Scenario: With raise_license_exception defined
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      site :opscode
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
    And the exit status should be 0

  Scenario: With a license that is not listed
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      site :opscode
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
    And the CLI should exit with the status code for error "LicenseNotAllowed"

  Scenario: With a :path location
    Given the cookbook store has the cookbooks:
      | fake | 0.1.0 | mit |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', path: '../berkshelf/cookbooks/fake-0.1.0'
      """
    And I have a Berkshelf config file containing:
      """
      {
        "allowed_licenses": ["apache2"],
        "raise_license_exception": true
      }
      """
    When I run `berks install`
    Then the output should not contain:
      """
      'mit' is not in your list of allowed licenses
      """
    And the exit status should be 0
