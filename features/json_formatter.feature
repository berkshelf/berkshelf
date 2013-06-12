Feature: --format json
  As a user
  I want to be able to get all output in JSON format
  So I can easily parse the output in scripts

  Scenario: JSON output installing a cookbook from the default location
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "version": "1.0.0",
            "location": "site: 'http://cookbooks.opscode.com/api/v1/cookbooks'",
            "name": "berkshelf-cookbook-fixture"
          }
        ],
        "errors": [

        ],
        "messages": [

        ]
      }
      """

  Scenario: JSON output installing a cookbook we already have
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "berkshelf-cookbook-fixture",
            "version": "1.0.0"
          }
        ],
        "errors": [

        ],
        "messages": [

        ]
      }
      """

  @chef_server
  Scenario: JSON output when running the upload command
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook | example_cookbook-0.5.0 |
    And the Chef server does not have the cookbooks:
      | example_cookbook | 0.5.0 |
    When I successfully run `berks upload --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "example_cookbook",
            "version": "0.5.0",
            "location": "../../spec/fixtures/cookbooks/example_cookbook-0.5.0",
            "uploaded_to": "http://localhost:4000/"
          }
        ],
        "errors": [

        ],
        "messages": [

        ]
      }
      """
