Feature: install cookbooks from a Berksfile
  As a user with a Berksfile
  I want to be able to run knife berkshelf install to install my cookbooks
  So that I don't have to download my cookbooks and their dependencies manually

  Scenario: installing a Berksfile that contains a source with a default location
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains the cookbook explicitly desired by a source
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using berkshelf-cookbook-fixture (1.0.0)
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that has multiple cookbooks in different groups
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And I write to "Berksfile" with:
      """
      group :a do
        cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      end

      group :b do
        cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      end
      """
    When I successfully run `berks install`
    Then the output should contain "Using berkshelf-cookbook-fixture (1.0.0)"
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a source with dependencies, all of which already have been installed
    Given the cookbook store contains a cookbook "berkshelf-cookbook-fixture" "1.0.0" with dependencies:
      | hostsfile    | = 1.0.1 |
    And the cookbook store has the cookbooks:
      | hostsfile    | 1.0.1 |
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'deps'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using hostsfile (1.0.1)
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a path location
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook | example_cookbook-0.5.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) at '
      """
    And the exit status should be 0

  Scenario: installing a Berksfile from a remote directory that contains a path location
    Given I write to "tmp_berks/Berksfile" with:
      """
      cookbook 'example_cookbook', path: '../../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks install -b ./tmp_berks/Berksfile`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) at '
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'master'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location that has already been downloaded
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git"
      """
    And the cookbook store has the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    And I successfully run `berks install`
    When I successfully run `berks install`
    Then the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location with a rel
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'rel', rel: 'cookbooks/berkshelf-cookbook-fixture'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 1.0.0 | 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0)
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location with a rel that has already been downloaded
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'rel', rel: 'cookbooks/berkshelf-cookbook-fixture'
      """
    And the cookbook store has the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 1.0.0 | 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a |
    And I successfully run `berks install`
    When I run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0)
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location with a tag
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (0.2.0) from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v0.2.0'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a GitHub location
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (0.2.0) from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v0.2.0'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Github location and the default protocol
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (0.2.0) from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v0.2.0' over protocol: 'git'
      """
    And the exit status should be 0

  Scenario Outline: installing a Berksfile that contains a Github location and specific protocol
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v1.0.0", protocol: "<protocol>"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks installed by git:
      | berkshelf-cookbook-fixture | 1.0.0 | b4f968c9001ad8de30f564a2107fab9cfa91f771 |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from github: 'RiotGames/berkshelf-cookbook-fixture' with branch: 'v1.0.0' over protocol: '<protocol>'
      """
    And the exit status should be 0

    Examples:
      | protocol |
      # | ssh   | # GitHub over ssh requires push authorization. Nonpushers will get a test failure here.
      | git |
      | https |

  Scenario: installing a Berksfile that contains a Github location and an unsupported protocol
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "RiotGames/berkshelf-cookbook-fixture", tag: "v0.2.0", protocol: "somethingabsurd"
      """
    When I run `berks install`
    Then the output should contain:
      """
      'somethingabsurd' is not supported for the 'github' location key - please use 'git' instead
      """
    And the exit status should be 110

  Scenario: installing a Berksfile that contains an explicit site location
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the exit status should be 0

  Scenario: running install when current project is a cookbook and the 'metadata' is specified
    Given a cookbook named "sparkle_motion"
    And the cookbook "sparkle_motion" has the file "Berksfile" with:
      """
      metadata
      """
    When I cd to "sparkle_motion"
    And I successfully run `berks install`
    Then the output should contain exactly:
      """
      Using sparkle_motion (0.0.0) from metadata

      """
    And the exit status should be 0

  Scenario: running install when current project is a cookbook and the 'metadata' is specified with a path
    Given a cookbook named "fake"
    And I write to "Berksfile" with:
      """
      metadata path: './fake'
      """
    When I successfully run `berks install`
    Then the output should contain exactly:
      """
      Using fake (0.0.0) from metadata at './fake'

      """
    And the exit status should be 0

  Scenario: running install with no Berksfile or Berksfile.lock
    Given I do not have a Berksfile
    And I do not have a Berksfile.lock
    When I run `berks install`
    Then the output should contain:
      """
      No Berksfile or Berksfile.lock found at '
      """
    And the CLI should exit with the status code for error "BerksfileNotFound"

  Scenario: running install when the Cookbook is not found on the remote site
    Given I write to "Berksfile" with:
      """
      cookbook 'doesntexist'
      """
    And I run `berks install`
    Then the output should contain:
      """
      Cookbook 'doesntexist' not found in any of the default locations
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: installing a Berksfile that has a Git location source with an invalid Git URI
    Given I write to "Berksfile" with:
      """
      cookbook 'nginx', git: '/something/on/disk'
      """
    When I run `berks install`
    Then the output should contain:
      """
      '/something/on/disk' is not a valid Git URI
      """
    And the CLI should exit with the status code for error "InvalidGitURI"

  Scenario: installing when there are sources with duplicate names defined in the same group
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture'
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Berksfile contains multiple sources named 'berkshelf-cookbook-fixture'. Use only one, or put them in different groups.
      """
    And the CLI should exit with the status code for error "DuplicateSourceDefined"

  Scenario: When a version constraint in the metadata exists, but does not satisfy
    Given a cookbook named "fake"
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', path: './fake'
      """
    And the cookbook "fake" has the file "metadata.rb" with:
      """
      name 'fake'
      version '1.0.0'

      depends 'berkshelf-cookbook-fixture', '~> 0.2.0'
      """
    And the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 |
    And I successfully run `berks install`
    And the cookbook "fake" has the file "metadata.rb" with:
      """
      name 'fake'
      version '1.0.0'

      depends 'berkshelf-cookbook-fixture', '~> 1.0.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0)
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  Scenario: installing when a git source defines a branch that does not satisfy the version constraint
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", "= 1.0.0", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I run `berks install`
    Then the output should match multiline:
      """
      The cookbook downloaded from git: 'git://github\.com/RiotGames/berkshelf-cookbook-fixture\.git' with branch: 'v0\.2\.0' at ref: '.+':
        berkshelf-cookbook-fixture \(.+\)

      does not satisfy the version constraint:
        berkshelf-cookbook-fixture \(= 1.0.0\)

      This occurs when the Chef Server has a cookbook with a missing/mis-matched version number in its `metadata.rb`
      """
    And the CLI should exit with the status code for error "CookbookValidationFailure"

  Scenario: when a git location source is defined and a cookbook of the same name is already cached in the cookbook store
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "git://github.com/RiotGames/berkshelf-cookbook-fixture.git", tag: "v1.0.0"
      """
    And the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git' with branch: 'v1.0.0' at ref:
      """
    And the exit status should be 0

  Scenario: with a cookbook definition containing an invalid option
    Given I write to "Berksfile" with:
      """
      cookbook "berkshelf-cookbook-fixture", whatisthis: "I don't even know", anotherwat: "isthat"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Invalid options for Cookbook Source: 'whatisthis', 'anotherwat'.
      """
    And the CLI should exit with the status code for error "InternalError"

  @chef_server
  Scenario: with a cookbook definition containing a chef_api source location
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', chef_api: :config
      """
    And the Chef server has cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from chef_api:
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  Scenario: when the :site is not defined
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0', site: nil
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site:
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  Scenario: with a chef_api source location specifying :config when a Berkshelf config is not found at the given path
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', chef_api: :config
      """
    When I run the install command with flags:
      | -c /tmp/notthere.lol |
    Then the output should contain:
      """
      No Berkshelf config file found at: '/tmp/notthere.lol'!
      """
    And the CLI should exit with the status code for error "ConfigNotFound"

  Scenario: with a git error during download
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      cookbook "doesntexist", git: "git://github.com/asdjhfkljashflkjashfakljsf"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Failed to download 'doesntexist' from git:
      """
      And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: invalid site symbol
    Given I write to "Berksfile" with:
      """
      site :somethingabsurd
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unknown site shortname 'somethingabsurd' - supported shortnames are:
      """
