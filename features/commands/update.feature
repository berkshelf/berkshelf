@api_server
Feature: berks update
  Background:
    * the cookbook store has the cookbooks:
      | fake | 0.1.0 |
      | fake | 0.2.0 |
      | fake | 1.0.0 |
      | ekaf | 1.0.0 |
      | ekaf | 1.0.1 |

  Scenario: Without a cookbook specified
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'ekaf', '~> 1.0.0'
      cookbook 'fake', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf (~> 1.0.0)
        fake (~> 0.1)

      GRAPH
        ekaf (1.0.0)
        fake (0.1.0)
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        ekaf (~> 1.0.0)
        fake (~> 0.1)

      GRAPH
        ekaf (1.0.1)
        fake (0.2.0)
      """

  Scenario: With a single cookbook specified
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'ekaf', '~> 1.0.0'
      cookbook 'fake', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf (~> 1.0.0)
        fake (~> 0.1)

      GRAPH
        ekaf (1.0.0)
        fake (0.1.0)
      """
    When I successfully run `berks update fake`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        ekaf (~> 1.0.0)
        fake (~> 0.1)

      GRAPH
        ekaf (1.0.0)
        fake (0.2.0)
      """

  Scenario: With a cookbook that does not exist
    Given I have a Berksfile pointing at the local Berkshelf API
    When I run `berks update not_real`
    Then the output should contain:
      """
      Could not find cookbook 'not_real'. Make sure it is in your Berksfile, then run `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "DependencyNotFound"
