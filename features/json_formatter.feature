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
    And the JSON response should have 1 cookbook
    And the JSON response at "cookbooks/0/version" should be "1.2.4"
