#
# The lifecycle feature contains a series of "long-running" lifecycle commands.
# These tests do not fit into a single command as they are cross-cutting and
# require more setup than a typical test.
#
# These tests are designed to mirror the real-world use cases for Berkshelf in
# day-to-day work. It also contains a collection of previously known bugs to
# prevent regressions.
#
Feature: Lifecycle commands
  Background:
    * the cookbook store has the cookbooks:
      | ekaf | 1.0.0 |
      | fake | 1.0.0 |

  Scenario: A trusted lockfile does not fetch the dependency index
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    * I successfully run `berks install`
    * the output should not contain "Fetching cookbook index"
    * the output should contain "Using fake (1.0.0)"

  Scenario: An untrusted lockfile fetches the dependency index
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I successfully run `berks install`
    * the output should contain "Fetching cookbook index"
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    * I append to "Berksfile" with:
      """

      cookbook 'ekaf', '1.0.0'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        ekaf (= 1.0.0)
        fake (= 1.0.0)

      GRAPH
        ekaf (1.0.0)
        fake (1.0.0)
      """
    * the output should contain "Using ekaf (1.0.0)"
    * the output should contain "Using fake (1.0.0)"

  Scenario: Removing a direct dependency
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf (= 1.0.0)
        fake (= 1.0.0)

      GRAPH
        ekaf (1.0.0)
        fake (1.0.0)
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    * the output should not contain "Using ekaf (1.0.0)"
    * the output should contain "Using fake (1.0.0)"

  Scenario: A trusted lockfile with transitive dependencies does not fetch the dependency index
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'transitive'
      version '1.2.3'
      depends 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (= 1.0.0)
      """
    * I successfully run `berks install`
    * the output should not contain "Fetching cookbook index"
    * the output should contain "Using fake (1.0.0)"
    * the output should contain "Using transitive (1.2.3)"

  Scenario: An utrusted lockfile because of transitive dependencies fetches the dependency index
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'transitive'
      version '1.2.3'
      depends 'fake', '1.0.0'
      """
    * I successfully run `berks install`
    * the output should contain "Fetching cookbook index"
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (= 1.0.0)
      """
    * I append to "metadata.rb" with:
      """

      depends 'ekaf', '1.0.0'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        ekaf (1.0.0)
        fake (1.0.0)
        transitive (1.2.3)
          ekaf (= 1.0.0)
          fake (= 1.0.0)
      """
    * the output should contain "Using ekaf (1.0.0)"
    * the output should contain "Using fake (1.0.0)"
    * the output should contain "Using transitive (1.2.3)"

  Scenario: Removing a transitive dependency
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'transitive'
      version '1.2.3'
      depends 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        ekaf (1.0.0)
        fake (1.0.0)
        transitive (1.2.3)
          ekaf (= 1.0.0)
          fake (= 1.0.0)
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (= 1.0.0)
      """
    * the output should not contain "Using ekaf (1.0.0)"
    * the output should contain "Using fake (1.0.0)"

  Scenario: Moving a transitive dependency to a direct dependency
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'transitive'
      version '1.2.3'
      depends 'fake', '1.0.0'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (= 1.0.0)
      """
    * the output should not contain "Using ekaf (1.0.0)"
    * the output should contain "Using fake (1.0.0)"
    * I write to "fake/metadata.rb" with:
      """
      name 'fake'
      version '1.0.0'
      """
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      cookbook 'fake', path: 'fake'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: fake
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (= 1.0.0)
      """

  Scenario: Moving a transitive dependency to a direct dependency and then removing it
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'transitive'
      version '1.2.3'
      depends 'fake'
      """
    * I successfully run `berks install`
    * I write to "fake/metadata.rb" with:
      """
      name 'fake'
      version '1.0.0'
      """
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      cookbook 'fake', path: 'fake'
      """
    * I successfully run `berks install`
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        transitive
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
        transitive (1.2.3)
          fake (>= 0.0.0)
      """

  Scenario: Bumping the version of a local cookbook
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    * I write to "metadata.rb" with:
      """
      name 'fake'
      version '1.0.0'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (1.0.0)
      """
    * I write to "metadata.rb" with:
      """
      name 'fake'
      version '1.0.1'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (1.0.1)
      """
    * the output should contain "Using fake (1.0.1)"

  Scenario: Switching a dependency to a new location
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    * I write to "Berksfile.lock" with:
       """
      DEPENDENCIES
        fake

      GRAPH
        fake (1.0.0)
       """
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', path: './fake'
      """
    * I write to "fake/metadata.rb" with:

      """
      name 'fake'
      version '2.0.0'
      """
    * I successfully run `berks install`
    * the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        fake
          path: fake

      GRAPH
        fake (2.0.0)
      """
    * the output should not contain "Using fake (1.0.0)"
    * the output should contain "Using fake (2.0.0)"
