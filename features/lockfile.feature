@api_server
Feature: Creating and reading the Berkshelf lockfile
  Background:
    * the cookbook store has the cookbooks:
      | fake | 0.1.0 |
      | fake | 0.2.0 |
      | fake | 1.0.0 |
    * the cookbook store has the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
      | berkshelf-cookbook-fixture | 1.0.0 | 919afa0c402089df23ebdf36637f12271b8a96b4 |
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
      | berkshelf-cookbook-fixture | 1.0.0 | 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a |

  Scenario: Writing the Berksfile.lock
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """

  Scenario: Writing the Berksfile.lock when a 2.0 lockfile is present
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sources": {
          "fake": {
            "locked_version": "1.0.0"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      It looks like you are using an older version of the lockfile.
      """
    And the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """

  Scenario: Reading the Berksfile.lock when it contains an invalid path location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        non-existent (~> 0.1)
          path: /this/path/does/not/exist
      """
    When I successfully run `berks install`
    And the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake

      GRAPH
        fake (1.0.0)
      """

  Scenario: Installing a cookbook with dependencies
    Given the cookbook store has the cookbooks:
      | dep | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        dep (1.0.0)
        fake (1.0.0)
          dep (~> 1.0.0)
      """

  Scenario: Writing the Berksfile.lock with a pessimistic lock
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (~> 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (~> 1.0.0)

      GRAPH
        fake (1.0.0)
      """

  Scenario: Updating with a Berksfile.lock with pessimistic lock
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (~> 0.1)

      GRAPH
        fake (0.1.0)
      """
    When I successfully run `berks update fake`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (~> 0.1)

      GRAPH
        fake (0.2.0)
      """

  Scenario: Updating with a Berksfile.lock with hard lock
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '0.1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 0.1.0)

      GRAPH
        fake (0.1.0)
      """
    When I successfully run `berks update fake`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 0.1.0)

      GRAPH
        fake (0.1.0)
      """

  Scenario: Updating a Berksfile.lock with a git location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', ref: '919afa0c4'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture.git
          ref: 919afa0c402089df23ebdf36637f12271b8a96b4

      GRAPH
        berkshelf-cookbook-fixture (1.0.0)
      """

  Scenario: Updating a Berksfile.lock with a git location and a branch
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', branch: 'master'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture.git
          ref: a97b9447cbd41a5fe58eee2026e48ccb503bd3bc

      GRAPH
        berkshelf-cookbook-fixture (1.0.0)
      """

  Scenario: Updating a Berksfile.lock with a git location and a branch
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', tag: 'v0.2.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture.git
          ref: 70a527e17d91f01f031204562460ad1c17f972ee

      GRAPH
        berkshelf-cookbook-fixture (0.2.0)
      """

  Scenario: Updating a Berksfile.lock with a GitHub location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', ref: '919afa0c4'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture.git
          ref: 919afa0c402089df23ebdf36637f12271b8a96b4

      GRAPH
        berkshelf-cookbook-fixture (1.0.0)
      """

  Scenario: Updating a Berksfile.lock when a git location with :rel
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'rel', rel: 'cookbooks/berkshelf-cookbook-fixture'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        berkshelf-cookbook-fixture
          git: git://github.com/RiotGames/berkshelf-cookbook-fixture.git
          ref: 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a
          rel: cookbooks/berkshelf-cookbook-fixture

      GRAPH
        berkshelf-cookbook-fixture (1.0.0)
      """

  Scenario: Updating a Berksfile.lock with a path location
    Given a cookbook named "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', path: './fake'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: ./fake

      GRAPH
        fake (0.0.0)
      """

  Scenario: Installing a Berksfile with a metadata location
    Given a cookbook named "fake"
    And I cd to "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (0.0.0)
      """

  Scenario: Installing a Berksfile with a locked metadata location
    Given a cookbook named "fake"
    And I cd to "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (0.0.0)
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (0.0.0)
      """

  Scenario: Installing when the locked version is no longer satisfied
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 1.3.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (~> 1.3.0)

      GRAPH
        fake (1.0.0)
      """
    When I run `berks install`
    Then the output should contain:
      """
      Berkshelf could not find compatible versions for cookbook 'fake':
        In Berksfile:
          fake (~> 1.3.0)

        In Berksfile.lock:
          fake (1.0.0)

      Try running `berks update fake`, which will try to find 'fake' matching '~> 1.3.0'
      """
    And the exit status should be "OutdatedDependency"

  Scenario: Installing when the Lockfile is empty
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And an empty file named "Berksfile.lock"
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using fake (1.0.0)
      """

  Scenario: Installing when the Lockfile is in a bad state
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    Given I write to "Berksfile.lock" with:
      """
      this is totally not valid
      """
    When I run `berks install`
    Then the output should contain:
      """
      Error reading the Berkshelf lockfile:
      """
    And the exit status should be "LockfileParserError"
