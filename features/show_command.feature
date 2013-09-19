Feature: Displaying information about a cookbook defined by a Berksfile
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: With no options
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the Lockfile has:
      | fake | 1.0.0 |
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


  Scenario: When the cookbook is not in the Berksfile
    Given I have a Berksfile pointing at the local Berkshelf API
    When I run `berks show fake`
    Then the output should contain:
      """
      Could not find cookbook(s) 'fake' in any of the configured dependencies. Is it in your Berksfile?
      """
    And the exit status should be "DependencyNotFound"


  Scenario: When there is no lockfile present
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I run `berks show fake`
    Then the output should contain:
      """
      Could not find cookbook 'fake (>= 0.0.0)'. Try running `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "LockfileNotFound"


  Scenario: When the cookbook is not installed
    Given the cookbook store is empty
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the Lockfile has:
      | fake | 1.0.0 |
    When I run `berks show fake`
    Then the output should contain:
      """
      Could not find cookbook 'fake (= 1.0.0)'. Try running `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "CookbookNotFound"
