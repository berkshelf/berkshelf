Feature: Packaging a cookbook as a tarball for distribution
  As a user
  I want to be able to package a cookbook
  So that I can use it outside of Berkshelf

  Scenario: When no options are passed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '~> 1.0.0'
      """
    When I successfully run `berks package fake`
    Then a file named "fake.tar.gz" should exist
    And the output should contain:
      """
      Cookbook(s) packaged to
      """
    And the exit status should be 0

  Scenario: With the --output option
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '~> 1.0.0'
      """
    When I successfully run `berks package fake --output foo/bar`
    Then a file named "foo/bar/fake.tar.gz" should exist
    And the exit status should be 0

  Scenario: With an installed cookbook name
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '~> 1.0.0'
      """
    When I run `berks package non-existent`
    Then a file named "non-existent.tar.gz" should not exist
    And the output should contain:
      """
      Cookbook 'non-existent' is not in your Berksfile
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: With an invalid cookbook
    Given a cookbook named "cookbook with spaces"
    And I write to "Berksfile" with:
      """
      cookbook 'cookbook with spaces', path: './cookbook with spaces'
      """
    When I run `berks package`
    Then the output should contain:
      """
      The cookbook 'cookbook with spaces' has invalid filenames:
      """
    And the CLI should exit with the status code for error "InvalidCookbookFiles"
