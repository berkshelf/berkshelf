Feature: --format json
  As a user
  I want to be able to get all output in JSON format
  So I can easily parse the output in scripts

  Scenario: JSON output installing a cookbook from the default location
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "= 1.2.4"
      """
    When I run the install command with flags:
      | --format json |
    Then the output should be JSON
    And the JSON at "cookbooks" should have 2 cookbooks
    And the JSON at "cookbooks/0/version" should be "1.2.4"
    And the JSON at "cookbooks/0/location" should be "site: 'http://cookbooks.opscode.com/api/v1/cookbooks'"

  Scenario: JSON output installing a cookbook we already have
    Given the cookbook store has the cookbooks:
      | mysql   | 1.2.4 |
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "= 1.2.4"
      """
    When I run the install command with flags:
      | --format json |
    Then the output should be JSON
    And the JSON at "cookbooks" should have 1 cookbook
    And the JSON at "cookbooks/0/version" should be "1.2.4"
    And the JSON should not have "cookbooks/0/location"

  @chef_server
  Scenario: JSON output when running the upload command
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook | example_cookbook-0.5.0 |
    And the Chef server does not have the cookbooks:
      | example_cookbook | 0.5.0 |
    When I run the upload command with flags:
      | --format json |
    Then the output should be JSON
    And the JSON at "cookbooks" should have 1 cookbook
    And the JSON at "cookbooks/0/version" should be "0.5.0"
    And the JSON should have "cookbooks/0/uploaded_to"
    And the Chef server should have the cookbooks:
      | example_cookbook | 0.5.0 |
