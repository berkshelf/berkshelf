Feature: Installing cookbooks from an Artifactory server
  This integration test uses some environment variables to configure which
  Artifactory server to talk to, as there is no ArtifactoryZero to test against.
  If those aren't present, we skip the tests.

  $TEST_BERKSHELF_ARTIFACTORY - URL to the Chef virtual repository.
  $TEST_BERKSHELF_ARTIFACTORY_API_KEY - API key to use.

  Scenario: when the cookbook exists
    Given I have a Berksfile pointing at an authenticated Artifactory server with:
      """
      cookbook 'poise', '2.7.2'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing poise (2.7.2)
      """
    And the cookbook store should have the cookbooks:
      | poise | 2.7.2 |

  Scenario: when the cookbook does not exist
    Given I have a Berksfile pointing at an authenticated Artifactory server with:
      """
      cookbook '1234567890'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: 1234567890 (>= 0.0.0)
      """
    And the exit status should be "NoSolutionError"

  Scenario: when the cookbook exists, but the version does not
    Given I have a Berksfile pointing at an authenticated Artifactory server with:
      """
      cookbook 'poise', '0.0.0'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: poise (= 0.0.0)
      """
    And the exit status should be "NoSolutionError"

  Scenario: when the API key is not present:
    Given I have a Berksfile pointing at an Artifactory server with:
      """
      cookbook 'poise'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: poise (>= 0.0.0)
      """
    And the exit status should be "NoSolutionError"

  Scenario: when the API key is given in $ARTIFACTORY_API_KEY:
    Given I have a Berksfile pointing at an Artifactory server with:
      """
      cookbook 'poise', '2.7.2'
      """
    And the environment variable ARTIFACTORY_API_KEY is $TEST_BERKSHELF_ARTIFACTORY_API_KEY
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing poise (2.7.2)
      """
    And the cookbook store should have the cookbooks:
      | poise | 2.7.2 |
