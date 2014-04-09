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

  Scenario: With a transitive dependency specified
    Given the cookbook store contains a cookbook "seth" "1.0.0" with dependencies:
      | fake | ~> 0.1 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'seth', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        seth (= 1.0.0)

      GRAPH
        fake (0.1.0)
        seth (1.0.0)
          fake (~> 0.1)
      """
    When I successfully run `berks update fake`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        seth (= 1.0.0)

      GRAPH
        fake (0.2.0)
        seth (1.0.0)
          fake (~> 0.1)
      """

  Scenario: With a git location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture
          revision: 70a527e17d91f01f031204562460ad1c17f972ee

      GRAPH
        berkshelf-cookbook-fixture (0.2.0)
      """
    And I successfully run `berks install`
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture
          revision: a97b9447cbd41a5fe58eee2026e48ccb503bd3bc

      GRAPH
        berkshelf-cookbook-fixture (1.0.0)
      """

  Scenario: With a cookbook that does not exist
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake

      GRAPH
        fake (0.2.0)
      """
    When I run `berks update not_real`
    Then the output should contain:
      """
      Dependency 'not_real' was not found. Please make sure it is in your Berksfile, and then run `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "DependencyNotFound"
