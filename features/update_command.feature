Feature: Updating a cookbook defined by a Berksfile
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Background:
    Given the cookbook store has the cookbooks:
      | fake | 0.1.0 |
      | fake | 0.2.0 |
      | fake | 1.0.0 |
      | ekaf | 1.0.0 |
      | ekaf | 1.0.1 |


  Scenario: Without a cookbook specified
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 0.1'
      cookbook 'ekaf', '~> 1.0.0'
      """
    And the Lockfile has:
      | fake | 0.1.0 |
      | ekaf | 1.0.0 |
    When I successfully run `berks update`
    Then the Lockfile should have:
      | fake | 0.2.0 |
      | ekaf | 1.0.1 |


  Scenario: With a single cookbook specified
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 0.1'
      cookbook 'ekaf', '~> 1.0.0'
      """
    And the Lockfile has:
      | fake | 0.1.0 |
      | ekaf | 1.0.0 |
    When I successfully run `berks update fake`
    Then the Lockfile should have:
      | fake | 0.2.0 |
      | ekaf | 1.0.0 |


  Scenario: With a cookbook that does not exist
    Given I have a Berksfile pointing at the local Berkshelf API
    When I run `berks update not_real`
    Then the output should contain:
      """
      Could not find cookbook(s) 'not_real' in any of the configured dependencies. Is it in your Berksfile?
      """
    And the exit status should be "DependencyNotFound"
