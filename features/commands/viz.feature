@graphviz
Feature: berks viz
  Scenario: With no options
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
    * I successfully run `berks viz`
    * a file named "graph.png" should exist

  Scenario: When there are transitive dependencies
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        dep (1.0.0)
        fake (1.0.0)
          dep (~> 1.0.0)
      """
    * I successfully run `berks viz`
    * a file named "graph.png" should exist

  Scenario: When a custom output is given
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        dep (1.0.0)
        fake (1.0.0)
          dep (~> 1.0.0)
      """
    * I successfully run `berks viz --outfile ponies.png`
    * a file named "graph.png" should not exist
    * a file named "ponies.png" should exist

  Scenario: When there is no lockfile present
    * I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    * I run `berks viz`
    * the output should contain:
      """
      Lockfile not found! Run `berks install` to create the lockfile.
      """
    * the exit status should be "LockfileNotFound"
