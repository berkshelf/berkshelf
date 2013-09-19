Feature: install cookbooks from a Berksfile
  As a user with a Berksfile
  I want a command to install the cookbooks defined in my Berksfile and their recursive dependencies
  So I don't have to download those cookbooks and their all of their dependencies manually

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty
    And the cookbook store is empty

  Scenario: installing the version that best satisfies our demand
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf'
      """
    And the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
      | berkshelf | 2.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf (2.0.0)
      """
    And the cookbook store should have the cookbooks:
      | berkshelf | 2.0.0 |

  Scenario: installing an explicit version demand
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf', '1.0.0'
      """
    And the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
      | berkshelf | 2.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf (1.0.0)
      """
    And the cookbook store should have the cookbooks:
      | berkshelf | 1.0.0 |

  Scenario: installing demands from all groups
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      group :one do
        cookbook 'ruby'
      end

      group :two do
        cookbook 'elixir'
      end
      """
    And the Chef Server has cookbooks:
      | ruby   | 1.0.0 |
      | elixir | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing ruby (1.0.0)
      Installing elixir (1.0.0)
      """
    And the cookbook store should have the cookbooks:
      | ruby   | 1.0.0 |
      | elixir | 1.0.0 |

  Scenario: installing a demand that has already been installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'deps'
      """
    And the cookbook store contains a cookbook "berkshelf" "1.0.0" with dependencies:
      | hostsfile    | = 1.0.1 |
    And the cookbook store has the cookbooks:
      | hostsfile    | 1.0.1 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using hostsfile (1.0.1)
      """

  Scenario: installing a demand from a path location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../fixtures/cookbooks/example_cookbook-0.5.0'
      """
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) path: '
      """

  Scenario: installing a Berksfile from a remote directory that contains a path location
    Given I have a Berksfile at "subdirectory" pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../../fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks install -b subdirectory/Berksfile`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) path: '
      """

  Scenario: installing a demand from a Git location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'master'
      building universe...
      Using berkshelf-cookbook-fixture (1.0.0) git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'master'
      """

  Scenario: installing a demand from a Git location that has already been installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git"
      """
    And the cookbook store has the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using berkshelf-cookbook-fixture (1.0.0) git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'master'
      """

  Scenario: installing a Berksfile that contains a Git location with a rel
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'rel', rel: 'cookbooks/berkshelf-cookbook-fixture'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'rel' over protocol: 'git'
      building universe...
      Using berkshelf-cookbook-fixture (1.0.0) github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'rel' over protocol: 'git'
      """

  Scenario: installing a Berksfile that contains a Git location with a tag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v0.2.0'
      building universe...
      Using berkshelf-cookbook-fixture (0.2.0) git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v0.2.0' at ref: '70a527e17d91f01f031204562460ad1c17f972ee'
      """

  Scenario: installing a Berksfile that contains a GitHub location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v0.2.0' over protocol: 'git'
      building universe...
      Using berkshelf-cookbook-fixture (0.2.0) github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v0.2.0' over protocol: 'git'
      """

  Scenario Outline: installing a Berksfile that contains a Github location and specific protocol
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v1.0.0", protocol: "<protocol>"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | b4f968c9001ad8de30f564a2107fab9cfa91f771 |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v1.0.0' over protocol: '<protocol>'
      building universe...
      Using berkshelf-cookbook-fixture (1.0.0) github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v1.0.0' over protocol: '<protocol>'
      """

    Examples:
      | protocol |
      | git |
      | https |

  Scenario: installing a Berksfile that contains a Github location and an unsupported protocol
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v0.2.0", protocol: "somethingabsurd"
      """
    When I run `berks install`
    Then the output should contain:
      """
      'somethingabsurd' is not supported for the 'github' location key - please use 'git' instead
      """
    And the exit status should be "InvalidGitURI"

  Scenario: running install when current project is a cookbook and the 'metadata' is specified
    Given a cookbook named "sparkle_motion"
    And I cd to "sparkle_motion"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using sparkle_motion (0.0.0)
      """

  Scenario: running install when current project is a cookbook and the 'metadata' is specified with a path
    Given a cookbook named "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata path: './fake'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using fake (0.0.0)
      """

  Scenario: running install when a Berksfile.lock is present
    Given the Chef Server has cookbooks:
      | bacon | 0.1.0 |
      | bacon | 0.2.0 |
      | bacon | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "bacon": {
            "locked_version": "0.2.0"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing bacon (0.2.0)
      """

  Scenario: running install with no Berksfile or Berksfile.lock
    When I run `berks install`
    Then the output should contain:
      """
      No Berksfile or Berksfile.lock found at '
      """
    And the exit status should be "BerksfileNotFound"

  Scenario: running install when the Cookbook is not found on the remote site
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'doesntexist'
      cookbook 'other-failure'
      """
    And I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: doesntexist (>= 0.0.0), other-failure (>= 0.0.0)
      """
    And the exit status should be "NoSolutionError"

  Scenario: installing a Berksfile that has a Git location source with an invalid Git URI
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'nginx', git: '/something/on/disk'
      """
    When I run `berks install`
    Then the output should contain:
      """
      '/something/on/disk' is not a valid Git URI
      """
    And the exit status should be "InvalidGitURI"

  Scenario: installing when there are sources with duplicate names defined in the same group
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture'
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Berksfile contains multiple entries named 'berkshelf-cookbook-fixture'. Use only one, or put them in different groups.
      """
    And the exit status should be "DuplicateDependencyDefined"

  Scenario: when a Git demand points to a branch that does not satisfy the version constraint
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", "1.0.0", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v0.2.0'
      The cookbook downloaded for berkshelf-cookbook-fixture (= 1.0.0) did not satisfy the constraint.
      """
    And the exit status should be "CookbookValidationFailure"

  Scenario: when a Git demand is defined and a cookbook of the same name and version is already in the cookbook store
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v1.0.0"
      """
    And the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v1.0.0'
      building universe...
      Using berkshelf-cookbook-fixture (1.0.0) git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v1.0.0' at ref: 'b4f968c9001ad8de30f564a2107fab9cfa91f771'
      """

  Scenario: with a cookbook definition containing an invalid option
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", whatisthis: "I don't even know", anotherwat: "isthat"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Invalid options for dependency: 'whatisthis', 'anotherwat'.
      """
    And the exit status should be "InternalError"

  Scenario: with a git error during download
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      cookbook "doesntexist", git: "git://github.com/asdjhfkljashflkjashfakljsf"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Fetching 'doesntexist' from git: 'git://github.com/asdjhfkljashflkjashfakljsf' with branch: 'master'
      An error occurred during Git execution:
      """
      And the exit status should be "GitError"

  Scenario: transitive dependencies in metadata
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | bacon | >= 0.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      metadata
      """
    And I write to "metadata.rb" with:
      """
      depends 'fake', '1.0.0'
      depends 'bacon', '0.2.0'
      """
    And the Chef Server has cookbooks:
      | bacon | 0.1.0 |
      | bacon | 0.2.0 |
      | bacon | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks:
      | bacon | 0.2.0 |
    Then the output should contain:
      """
      Installing bacon (0.2.0)
      """

  Scenario: transitive dependencies in metadata when cookbooks are downloaded
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | bacon | >= 0.0.0 |
    And the cookbook store has the cookbooks:
      | bacon | 1.0.0 |
      | bacon | 0.3.0 |
      | bacon | 0.2.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      metadata
      """
    And I write to "metadata.rb" with:
      """
      depends 'fake', '1.0.0'
      depends 'bacon', '0.2.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using bacon (0.2.0)
      """
