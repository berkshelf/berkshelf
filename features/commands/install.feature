Feature: berks install
  Background:
    * the Chef Server is empty
    * the cookbook store is empty

  Scenario: installing the version that best satisfies our demand
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf'
      """
    And the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
      | berkshelf | 2.0.0 |
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
    When I successfully run `berks install`
    Then the output should contain "Installing elixir (1.0.0)"
    And the output should contain "Installing ruby (1.0.0)"
    And the cookbook store should have the cookbooks:
      | ruby   | 1.0.0 |
      | elixir | 1.0.0 |

  Scenario: installing a demand that has already been installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture',
        github: 'chef/berkshelf-cookbook-fixture',
        branch: 'deps'
      """
    And the cookbook store contains a cookbook "berkshelf" "1.0.0" with dependencies:
      | hostsfile | = 1.0.1 |
    And the cookbook store has the cookbooks:
      | hostsfile | 1.0.1 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using hostsfile (1.0.1)
      """

  Scenario: installing a single groups of demands with the --only flag
    Given the cookbook store has the cookbooks:
      | takeme | 1.0.0 |
      | notme  | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'takeme', group: :take_me
      cookbook 'notme', group: :not_me
      """
    When I successfully run `berks install --only take_me`
    Then the output should contain "Using takeme (1.0.0)"
    Then the output should not contain "Using notme (1.0.0)"

  Scenario: installing multiple groups of demands with the --only flag
    Given the cookbook store has the cookbooks:
      | takeme | 1.0.0 |
      | notme | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'takeme', group: :take_me
      cookbook 'notme', group: :not_me
      """
    When I successfully run `berks install --only take_me not_me`
    Then the output should contain "Using takeme (1.0.0)"
    Then the output should contain "Using notme (1.0.0)"

  Scenario: skipping a single group to install with the --except flag
    Given the cookbook store has the cookbooks:
      | takeme | 1.0.0 |
      | notme | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'takeme', group: :take_me
      cookbook 'notme', group: :not_me
      """
    When I successfully run `berks install --except not_me`
    Then the output should contain "Using takeme (1.0.0)"
    Then the output should not contain "Using notme (1.0.0)"

  Scenario: skipping multiple groups to install with the --except flag
    Given the cookbook store has the cookbooks:
      | takeme | 1.0.0 |
      | notme | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'takeme', group: :take_me
      cookbook 'notme', group: :not_me
      """
    When I successfully run `berks install --except take_me not_me`
    Then the output should not contain "Using takeme (1.0.0)"
    Then the output should not contain "Using notme (1.0.0)"

  Scenario: installing a demand from a path location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) from source at ../../spec/fixtures/cookbooks/example_cookbook-0.5.0
      """

  Scenario: installing a demand from a path location with a conflicting constraint
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', '~> 1.0.0', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I run `berks install`
    Then the output should contain:
      """
      The cookbook downloaded for example_cookbook (~> 1.0.0) did not satisfy the constraint.
      """

  Scenario: installing a demand from a path location that also exists in other locations with conflicting dependencies
    Given the Chef Server has cookbooks:
      | example_cookbook | 0.5.0 | missing_cookbook >= 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) from source at ../../spec/fixtures/cookbooks/example_cookbook-0.5.0
      """

  Scenario: installing a demand from a path location locks the graph to that version
    Given the Chef Server has cookbooks:
      | other_cookbook   | 1.0.0 | example_cookbook ~> 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      cookbook 'other_cookbook'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Unable to find a solution for demands: example_cookbook (0.5.0), other_cookbook (>= 0.0.0)
      """

  Scenario: installing a Berksfile from a remote directory that contains a path location
    Given I have a Berksfile at "subdirectory" pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks install -b subdirectory/Berksfile`
    Then the output should contain:
      """
      Using example_cookbook (0.5.0) from source at ../../../spec/fixtures/cookbooks/example_cookbook-0.5.0
      """

  Scenario: installing a demand from a Git location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at master)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (1.0.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at master)
      """

  Scenario: installing a demand from a Git location that has already been installed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git"
      """
    And the cookbook store has the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | a97b9447cbd41a5fe58eee2026e48ccb503bd3bc |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using berkshelf-cookbook-fixture (1.0.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at master)
      """

  Scenario: installing a Berksfile that contains a Git location with a rel
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture',
        github: 'chef/berkshelf-cookbook-fixture',
        branch: 'rel',
        rel:    'cookbooks/berkshelf-cookbook-fixture'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 | 93f5768b7d14df45e10d16c8bf6fe98ba3ff809a |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at rel/cookbooks/berkshelf-cookbook-fixture)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (1.0.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at rel/cookbooks/berkshelf-cookbook-fixture)
      """

  Scenario: installing a Berksfile that contains a Git location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture',
        git: 'https://github.com/chef/berkshelf-cookbook-fixture.git',
        tag: 'v0.2.0'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the git cookbook "berkshelf-cookbook-fixture-70a527e17d91f01f031204562460ad1c17f972ee" should not have the following directories:
      | .git |

  Scenario: installing a Berksfile that contains a Git location with a tag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (0.2.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      """

  Scenario: installing a Berksfile that contains a Git location with a ref
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git", ref: "70a527e17d91f01f031204562460ad1c17f972ee"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at 70a527e)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (0.2.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at 70a527e)
      """

  Scenario: installing a Berksfile that contains a Git location with an abbreviated ref
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git", ref: "70a527e"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at 70a527e)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (0.2.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at 70a527e)
      """

  Scenario: installing a Berksfile that contains a GitHub location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "chef/berkshelf-cookbook-fixture", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (0.2.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      """

  Scenario: installing a Berksfile that contains a GitHub location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", github: "chef/berkshelf-cookbook-fixture", tag: "v0.2.0"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the git cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 | 70a527e17d91f01f031204562460ad1c17f972ee |
    And the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (0.2.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      """

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
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon (~> 0.1)

      GRAPH
        bacon (0.2.0)
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

  Scenario: running install when the Cookbook from Berksfile.lock is not found in the sources
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'foo'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        foo

      GRAPH
        foo (0.1.0)
      """
    When I run `berks install`
    Then the output should contain:
      """
      Cookbook 'foo' (0.1.0) not found in any of the sources! This can happen if the remote cookbook has been deleted or if the sources inside the Berksfile have changed. Please run `berks update foo` to resolve to a valid version.
      """

  Scenario: running install when the version from Berksfile.lock is not found in the sources
    Given the Chef Server has cookbooks:
      | foo | 0.3.0 |
      | foo | 0.2.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'foo'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        foo

      GRAPH
        foo (0.1.0)
      """
    When I run `berks install`
    Then the output should contain:
      """
      Cookbook 'foo' (0.1.0) not found in any of the sources! This can happen if the remote cookbook has been deleted or if the sources inside the Berksfile have changed. Please run `berks update foo` to resolve to a valid version.
      """

  Scenario: installing when there are sources with duplicate names defined in the same group
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture'
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Your Berksfile contains multiple entries named 'berkshelf-cookbook-fixture'. Please remove duplicate dependencies, or put them in different groups.
      """
    And the exit status should be "DuplicateDependencyDefined"

  Scenario: when a Git demand points to a branch that does not satisfy the version constraint
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", "1.0.0", git: "https://github.com/chef/berkshelf-cookbook-fixture.git", tag: "v0.2.0"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at v0.2.0)
      The cookbook downloaded for berkshelf-cookbook-fixture (= 1.0.0) did not satisfy the constraint.
      """
    And the exit status should be "CookbookValidationFailure"

  Scenario: when a Git demand is defined and a cookbook of the same name and version is already in the cookbook store
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook "berkshelf-cookbook-fixture", git: "https://github.com/chef/berkshelf-cookbook-fixture.git", tag: "v1.0.0"
      """
    And the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Fetching 'berkshelf-cookbook-fixture' from https://github.com/chef/berkshelf-cookbook-fixture.git (at v1.0.0)
      Fetching cookbook index from http://127.0.0.1:26310...
      Using berkshelf-cookbook-fixture (1.0.0) from https://github.com/chef/berkshelf-cookbook-fixture.git (at v1.0.0)
      """

  Scenario: with a git error during download
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      cookbook "doesntexist", git: "https://github.com/asdjhfkljashflkjashfakljsf"
      """
    When I run `berks install`
    Then the exit status should be "GitError"

  Scenario: transitive dependencies in metadata
    Given the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | bacon | >= 0.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    And I write to "metadata.rb" with:
      """
      name "myface"
      depends 'fake', '1.0.0'
      depends 'bacon', '0.2.0'
      """
    And the Chef Server has cookbooks:
      | bacon | 0.1.0 |
      | bacon | 0.2.0 |
      | bacon | 1.0.0 |
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
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    And I write to "metadata.rb" with:
      """
      name "myface"
      depends 'fake', '1.0.0'
      depends 'bacon', '0.2.0'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using bacon (0.2.0)
      """

  Scenario: when asking for the :ruby solver engine without precedence, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :ruby
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when asking for the :gecode solver engine without precedence, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :gecode
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when asking for an unknown solver engine without precedence, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :unknown
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when preferring the :gecode solver engine, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :gecode, :preferred
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when preferring an unknown solver engine, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :unknown, :preferred
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when requiring an unknown solver engine, an error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :unknown, :required
    """
  When I run `berks install`
  Then the output should contain:
    """
    Engine `unknown` is not supported.
    """
    And the exit status should be "ArgumentError"

  Scenario: when requiring the :ruby solver engine, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :ruby, :required
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when requiring the :gecode solver engine, no error is raised
  Given I have a Berksfile pointing at the local Berkshelf API with:
    """
    cookbook 'example_cookbook', path: '../../spec/fixtures/cookbooks/example_cookbook-0.5.0'
    solver :gecode, :required
    """
  When I successfully run `berks install`
  Then the output should contain:
    """
    Resolving cookbook dependencies...
    """

  Scenario: when using a chef_repo source
    Given I use a fixture named "complex-cookbook-path"
    And a file named "Berksfile" with:
      """
      source({ :chef_repo => '.' })

      cookbook 'jenkins-config'
      """
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing jenkins (2.0.1) from
      """
    And the output should contain:
     """
     Installing jenkins-config (0.1.0) from
     """
    And the cookbook store should have the cookbooks:
      | jenkins        | 2.0.1 |
      | jenkins-config | 0.1.0 |

