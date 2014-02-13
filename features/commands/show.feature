Feature: berks show
  Scenario: With no options
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
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

  Scenario: When the parameter is a transitive dependency
    Given the cookbook store has the cookbooks:
      | dep | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        dep (1.0.0)
        fake (1.0.0)
          dep (~> 1.0.0)
      """
    And I successfully run `berks install`
    When I successfully run `berks show dep`
    Then the output should contain:
      """
              Name: dep
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
      Could not find cookbook 'fake'. Make sure it is in your Berksfile, then run `berks install` to download and install the missing dependencies.
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
      Could not find cookbook 'fake'. Make sure it is in your Berksfile, then run `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "DependencyNotFound"

  Scenario: When the cookbook is not installed
    Given the cookbook store is empty
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I run `berks show fake`
    Then the output should contain:
      """
      Could not find cookbook 'fake (1.0.0)'. Run `berks install` to download and install the missing cookbook.
      """
    And the exit status should be "CookbookNotFound"
