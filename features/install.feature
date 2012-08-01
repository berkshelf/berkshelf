Feature: install cookbooks from a Berksfile
  As a user with a Berksfile
  I want to be able to run knife berkshelf install to install my cookbooks
  So that I don't have to download my cookbooks and their dependencies manually

  Scenario: installing a Berksfile that contains a source with a default location
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I run the install command
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
    When I run the install command
    Then the output should contain:
      """
      Using mysql (1.2.4)
      """
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
    When I run the install command
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
    When I run the install command
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) at path:
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a path location which contains a broken symlink
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook_broken_link | example_cookbook_broken_link |
    When I run the install command with flags:
      | --shims |
    Then the following directories should exist:
      | cookbooks                  |
      | cookbooks/example_cookbook |
    And the output should contain:
      """
      Shims written to: 
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains a Git location
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.9.8"
      """
    When I run the install command
    Then the cookbook store should have the git cookbooks:
      | artifact | 0.9.8 | c0a0b456a4716a81645bef1369f5fd1a4e62ce6d |
    And the output should contain:
      """
      Installing artifact (0.9.8) from git: 'git://github.com/RiotGames/artifact-cookbook.git' with branch: '0.9.8'
      """
    And the exit status should be 0

  Scenario: installing a Berksfile that contains an explicit site location
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4", site: "http://cookbooks.opscode.com/api/v1/cookbooks"
      """
    When I run the install command
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
    And I run the install command
    Then the output should contain:
      """
      Using sparkle_motion (0.0.0) at path:
      """
    And the exit status should be 0

  Scenario: running install with no Berksfile or Berksfile.lock
    Given I do not have a Berksfile
    And I do not have a Berksfile.lock
    When I run the install command
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
    And I run the install command
    Then the output should contain:
      """
      Cookbook 'doesntexist' not found at site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the CLI should exit with the status code for error "DownloadFailure"

  Scenario: running install command with the --shims flag to create a directory of shims
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I run the install command with flags:
      | --shims |
    Then the following directories should exist:
      | cookbooks       |
      | cookbooks/mysql |
    And the output should contain:
      """
      Shims written to: 
      """
    And the exit status should be 0

  Scenario: running install with --shims when current project is a cookbook and the 'metadata' is specified
    Given a cookbook named "sparkle_motion"
    And the cookbook "sparkle_motion" has the file "Berksfile" with:
      """
      metadata
      """
    When I cd to "sparkle_motion"
    And I run the install command with flags:
      | --shims |
    Then the following directories should exist:
      | cookbooks                |
      | cookbooks/sparkle_motion |
    And the output should contain:
      """
      Shims written to: 
      """
    And the output should contain:
      """
      Using sparkle_motion (0.0.0) at path:
      """
    And the exit status should be 0


  Scenario: installing a Berksfile that has a Git location source with an invalid Git URI
    Given I write to "Berksfile" with:
      """
      cookbook "nginx", git: "/something/on/disk"
      """
    When I run the install command
    Then the output should contain:
      """
      '/something/on/disk' is not a valid Git URI.
      """
    And the CLI should exit with the status code for error "InvalidGitURI"

  Scenario: installing when there are sources with duplicate names defined
    Given I write to "Berksfile" with:
      """
      cookbook "artifact"
      cookbook "artifact"
      """
    When I run the install command
    Then the output should contain:
      """
      Berksfile contains two sources named 'artifact'. Remove one and try again.
      """
    And the CLI should exit with the status code for error "DuplicateSourceDefined"

  Scenario: installing when a git source defines a branch that does not satisfy the version constraint
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "= 0.9.8", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.10.0"
      """
    When I run the install command
    Then the output should contain:
      """
      A cookbook satisfying 'artifact' (= 0.9.8) not found at git: 'git://github.com/RiotGames/artifact-cookbook.git' with branch: '0.10.0'
      """
    And the CLI should exit with the status code for error "ConstraintNotSatisfied"

  Scenario: when a git location source is defined and a cookbook of the same name is already cached in the cookbook store
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.10.0"
      """
    And the cookbook store has the cookbooks:
      | artifact | 0.10.0 |
    When I run the install command
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
    When I run the install command
    Then the output should contain:
      """
      Invalid options for Cookbook Source: 'whatisthis', 'anotherwat'.
      """
    And the CLI should exit with the status code for error "InternalError"

  Scenario: with a cookbook definition containing a chef_api source location
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: :knife
      """
    And the Chef server has cookbooks:
      | artifact | 0.10.0 |
    When I run the install command
    Then the output should contain:
      """
      Installing artifact (0.10.0) from chef_api:
      """
    And the cookbook store should have the cookbooks:
      | artifact | 0.10.0 |
    And the exit status should be 0

  Scenario: with a chef_api source location specifying :knife when a Knife config is not found at the given path
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: :knife
      """
    When I run the install command with flags:
      | -c /tmp/nothere.lol |
    Then the output should contain:
      """
      A Knife config is required when ':knife' is given for the value of a 'chef_api' location. Attempted to load configuration from: '/tmp/nothere.lol' but not found.
      """
    And the CLI should exit with the status code for error "KnifeConfigNotFound"

  Scenario: with a chef_api source location specifying a Chef API URL but missing a node_name option
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: "https://api.opscode.com/organizations/vialstudios", client_key: "/Users/reset/.chef/knife.rb"
      """
    When I run the install command
    Then the output should contain:
      """
      Source 'artifact' is a 'chef_api' location with a URL for it's value but is missing options: 'node_name'.
      """
    And the CLI should exit with the status code for error "InvalidChefAPILocation"

  Scenario: with a chef_api source location specifying a Chef API URL but missing a client_key option
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: "https://api.opscode.com/organizations/vialstudios", node_name: "reset"
      """
    When I run the install command
    Then the output should contain:
      """
      Source 'artifact' is a 'chef_api' location with a URL for it's value but is missing options: 'client_key'.
      """
    And the CLI should exit with the status code for error "InvalidChefAPILocation"

  Scenario: with a chef_api source location specifying a Chef API URL but missing a client_key option
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", chef_api: "https://api.opscode.com/organizations/vialstudios"
      """
    When I run the install command
    Then the output should contain:
      """
      Source 'artifact' is a 'chef_api' location with a URL for it's value but is missing options: 'node_name', 'client_key'.
      """
    And the CLI should exit with the status code for error "InvalidChefAPILocation"
