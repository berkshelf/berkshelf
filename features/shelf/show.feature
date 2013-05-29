Feature: Displaying information about a cookbook in the Berkshelf shelf
  As a user with a cookbook store
  I want to show information about a specific cookbook in my cookbook store
  So that I can be well informed

  Scenario: With a cookbook that is not in the store
    When I run `berks shelf show fake`
    Then the output should contain:
      """
      Cookbook 'fake' is not in the Berkshelf shelf
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: With cookbooks in the store
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.3.4 |
    When I successfully run `berks shelf show fake`
    Then the output should contain:
      """
      Displaying all versions of 'fake' in the Berkshelf shelf:
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the output should not contain:
      """
      Name: ekaf
      """
    And the exit status should be 0


  Scenario: With cookbooks in the store and the --version option
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.3.4 |
    When I successfully run `berks shelf show fake --version 1.0.0`
    Then the output should contain:
      """
      Displaying 'fake' (1.0.0) in the Berkshelf shelf:
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the output should not contain:
      """
      Name: ekaf
      """
    And the exit status should be 0

  Scenario: With cookbooks in the store and the --version option doesn't exist
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.3.4 |
    When I run `berks shelf show fake --version 1.2.3`
    Then the output should contain:
      """
      Cookbook 'fake' (1.2.3) is not in the Berkshelf shelf
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: With multiple cookbook versions installed
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    When I successfully run `berks shelf show fake`
    Then the output should contain:
      """
      Displaying all versions of 'fake' in the Berkshelf shelf:
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none

              Name: fake
           Version: 1.1.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none

              Name: fake
           Version: 1.2.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none

              Name: fake
           Version: 2.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the exit status should be 0

  Scenario: With multiple cookbook versions installed and the --version flag
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | fake | 1.1.0 |
      | fake | 1.2.0 |
      | fake | 2.0.0 |
    When I successfully run `berks shelf show fake --version 1.0.0`
    Then the output should contain:
      """
      Displaying 'fake' (1.0.0) in the Berkshelf shelf:
              Name: fake
           Version: 1.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the output should not contain:
      """
              Name: fake
           Version: 1.1.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the output should not contain:
      """
              Name: fake
           Version: 1.2.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the output should not contain:
      """
              Name: fake
           Version: 2.0.0
       Description: A fabulous new cookbook
            Author: YOUR_COMPANY_NAME
             Email: YOUR_EMAIL
           License: none
      """
    And the exit status should be 0
