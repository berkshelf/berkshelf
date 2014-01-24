Feature: Installing cookbooks from the community site
  Scenario: when the cookbook exists
    Given I have a Berksfile pointing at the community API endpoint with:
      """
      cookbook 'apache2', '1.6.6'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing apache2 (1.6.6)
      """
    And the cookbook store should have the cookbooks:
      | apache2 | 1.6.6 |

  Scenario: when the cookbook does not exist
    Given I have a Berksfile pointing at the community API endpoint with:
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
    Given I have a Berksfile pointing at the community API endpoint with:
      """
      cookbook 'apache2', '0.0.0'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: apache2 (= 0.0.0)
      """
    And the exit status should be "NoSolutionError"
