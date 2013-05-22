Feature: info command
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: Running the info command
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks info fake`
    Then the output should contain:
      """
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """

  Scenario: Running the info command with a version flag
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks info fake --version 1.0.0`
    Then the output should contain:
      """
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """

  Scenario: Running the info command for a cookbook that is not defined in the Berksfile
    Given an empty file named "Berksfile"
    When I run `berks info fake`
    Then the output should contain "Cookbook 'fake' is not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"


# 7.66
