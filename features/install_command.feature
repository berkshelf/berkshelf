Feature: install cookbooks from a Berksfile
  As a user with a Berksfile
  I want to be able to run knife berkshelf install to install my cookbooks
  So that I don't have to download my cookbooks and their dependencies manually

  Scenario: installing a Berksfile that contains a source with a default location
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the output should contain:
      """
      Installing mysql (1.2.4) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      Installing openssl (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains the cookbook explicitly desired by a source
    Given the cookbook store has the cookbooks:
      | mysql   | 1.2.4 |
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "= 1.2.4"
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using mysql (1.2.4)
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that has multiple cookbooks in different groups
    Given the cookbook store has the cookbooks:
      | build-essential   | 1.1.2 |
    And I write to "Berksfile" with:
      """
      group :a do
        cookbook "build-essential", "1.1.2"
      end

      group :b do
        cookbook "build-essential", "1.1.2"
      end
      """
    When I successfully run `berks install`
    Then the output should contain "Using build-essential (1.1.2)"
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a source with dependencies, all of which already have been installed
    Given the cookbook store contains a cookbook "mysql" "1.2.4" with dependencies:
      | openssl      | = 1.0.0 |
      | windows      | = 1.3.0 |
      | chef_handler | = 1.0.6 |
    And the cookbook store has the cookbooks:
      | openssl      | 1.0.0 |
      | windows      | 1.3.0 |
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "~> 1.2.0"
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using mysql (1.2.4)
      Using openssl (1.0.0)
      Using windows (1.3.0)
      Installing chef_handler (1.0.6) from site:
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a path location
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook | example_cookbook-0.5.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) at path:
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.9.8"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | artifact | 0.9.8 | c0a0b456a4716a81645bef1369f5fd1a4e62ce6d |
    And the output should contain:
      """
      Installing artifact (0.9.8) from git: 'git://github.com/RiotGames/artifact-cookbook.git' with branch: '0.9.8'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a GitHub location
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", github: "RiotGames/artifact-cookbook", ref: "0.9.8"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | artifact | 0.9.8 | c0a0b456a4716a81645bef1369f5fd1a4e62ce6d |
    And the output should contain:
      """
      Installing artifact (0.9.8) from github: 'RiotGames/artifact-cookbook' with branch: '0.9.8'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Github location and the default protocol
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", github: "RiotGames/artifact-cookbook", ref: "0.9.8"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | artifact | 0.9.8 | c0a0b456a4716a81645bef1369f5fd1a4e62ce6d |
    And the output should contain:
      """
      Installing artifact (0.9.8) from github: 'RiotGames/artifact-cookbook' with branch: '0.9.8' over protocol: 'git'
      """
    And the exit status should be 0

  Scenario Outline: installing a Berksfile that contains a Github location and specific protocol
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", github: "RiotGames/artifact-cookbook", ref: "0.9.8", protocol: "<protocol>"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | artifact | 0.9.8 | c0a0b456a4716a81645bef1369f5fd1a4e62ce6d |
    And the output should contain:
      """
      Installing artifact (0.9.8) from github: 'RiotGames/artifact-cookbook' with branch: '0.9.8' over protocol: '<protocol>'
      """
    And the exit status should be 0

    Examples:
      | protocol |
      # GitHub over ssh requires push authorization. Nonpushers will
      # get a test failure here.
      # | ssh   |
      | https |

  Scenario: installing a Berksfile that contains a Github location and an unsupported protocol
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", github: "RiotGames/artifact-cookbook", ref: "0.9.8", protocol: "somethingabsurd"
      """
    When I run `berks install`
    Then the output should contain:
      """
      'somethingabsurd' is not a supported Git protocol for the 'github' location key. Please use 'git' instead.
      """
    And the exit status should be 110

  Scenario: installing a Berksfile that contains an explicit site location
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4", site: "http://cookbooks.opscode.com/api/v1/cookbooks"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the output should contain:
      """
      Installing mysql (1.2.4) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      Installing openssl (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
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
    Then the output should contain:
      """
      Using sparkle_motion (0.0.0) at path:
      """
    And the exit status should be 0

  Scenario: running install with no Berksfile or Berksfile.lock
    Given I do not have a Berksfile
    And I do not have a Berksfile.lock
    When I run `berks install`
    Then the output should contain:
      """
      No Berksfile or Berksfile.lock found at:
      """
    And the CLI should exit with the status code for error "BerksfileNotFound"

  Scenario: running install when the Cookbook is not found on the remote site
    Given I write to "Berksfile" with:
      """
      cookbook "doesntexist"
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
      cookbook "nginx", git: "/something/on/disk"
      """
    When I run `berks install`
    Then the output should contain:
      """
      '/something/on/disk' is not a valid Git URI.
      """
    And the CLI should exit with the status code for error "InvalidGitURI"

  Scenario: installing when there are sources with duplicate names defined in the same group
    Given I write to "Berksfile" with:
      """
      cookbook "artifact"
      cookbook "artifact"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Berksfile contains multiple sources named 'artifact'. Use only one, or put them in different groups.
      """
    And the CLI should exit with the status code for error "DuplicateSourceDefined"

  Scenario: installing when a git source defines a branch that does not satisfy the version constraint
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "= 0.9.8", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.10.0"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Cookbook downloaded for 'artifact' from git: 'git://github.com/RiotGames/artifact-cookbook.git' with branch: '0.10.0' does not satisfy the version constraint (= 0.9.8)
      """
    And the CLI should exit with the status code for error "CookbookValidationFailure"

  Scenario: when a git location source is defined and a cookbook of the same name is already cached in the cookbook store
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.10.0"
      """
    And the cookbook store has the cookbooks:
      | artifact | 0.10.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing artifact (0.10.0) from git: 'git://github.com/RiotGames/artifact-cookbook.git' with branch: '0.10.0'
      """
    And the exit status should be 0

  Scenario: with a cookbook definition containing an invalid option
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", whatisthis: "I don't even know", anotherwat: "isthat"
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
      cookbook "cuke-test", "= 1.0.0", chef_api: :config
      """
    And the Chef server has cookbooks:
      | cuke-test | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing cuke-test (1.0.0) from chef_api:
      """
    And the cookbook store should have the cookbooks:
      | cuke-test | 1.0.0 |
    And the exit status should be 0

  Scenario: with a chef_api source location specifying :config when a Berkshelf config is not found at the given path
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: :config
      """
    When I run the install command with flags:
      | -c /tmp/notthere.lol |
    Then the output should contain:
      """
      You specified a path to a configuration file that did not exist: '/tmp/notthere.lol'
      """
    And the CLI should exit with the status code for error "BerksConfigNotFound"

  Scenario: with a git error during download
    Given I write to "Berksfile" with:
      """
      cookbook "ohai", "1.1.4"
      cookbook "doesntexist", git: "git://github.com/asdjhfkljashflkjashfakljsf"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Installing ohai (1.1.4) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      Failed to download 'doesntexist' from git: 'git://github.com/asdjhfkljashflkjashfakljsf'
      An error occured during Git execution:
      """
      And the CLI should exit with the status code for error "GitError"
