Feature: Displaying information about a cookbook defined by a Berksfile
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: With no options
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks show fake`
    Then the output should contain:
      """
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """

  Scenario: When JSON is requested
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks show fake --format json`
    Then the output should contain:
      """
      {
        "cookbooks": [
          {
            "name": "fake",
            "version": "1.0.0",
            "description": "A fabulous new cookbook",
            "author": "YOUR_COMPANY_NAME",
            "email": "YOUR_EMAIL",
            "license": "none"
          }
        ],
        "errors": [

        ],
        "messages": [

        ]
      }
      """

  Scenario: When the cookbook is not in the Berksfile
    Given an empty file named "Berksfile"
    When I run `berks show fake`
    Then the output should contain "Cookbook 'fake' is not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
