Feature: berks upload
  Background:
    * the Chef Server is empty
    * the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
      | oops | 3.0.0 |

  Scenario: multiple cookbooks with no arguments
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)
        ekaf (= 2.0.0)

      GRAPH
        fake (1.0.0)
        ekaf (2.0.0)
      """
    When I successfully run `berks upload`
    Then the Chef Server should have the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |

  Scenario: a cookbook with a path location
    Given a cookbook named "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', path: './fake'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake
          path: ./fake

      GRAPH
        fake (0.0.0)
      """
    When I successfully run `berks upload`
    Then the Chef Server should have the cookbooks:
      | fake | 0.0.0 |

  Scenario: specifying a single cookbook with dependencies
    Given the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | = 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake',  '1.0.0'
      cookbook 'ekaf',  '2.0.0'
      cookbook 'reset', '3.4.5'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf (= 2.0.0)
        fake (= 1.0.0)
        reset (= 3.4.5)

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
        reset (3.4.5)
          fake (= 1.0.0)
      """
    When I successfully run `berks upload reset`
    Then the Chef Server should have the cookbooks:
      | reset | 3.4.5 |
    And the Chef Server should not have the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |

  Scenario: specifying a single cookbook that is a transitive dependency
    Given the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'reset', '3.4.5'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        reset (= 3.4.5)

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
        reset (3.4.5)
          ekaf (= 2.0.0)
          fake (= 1.0.0)
      """
    When I successfully run `berks upload fake`
    Then the Chef Server should have the cookbooks:
      | fake  | 1.0.0 |

  Scenario: specifying a dependency not defined in the Berksfile
    Given I have a Berksfile pointing at the local Berkshelf API
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I run `berks upload reset`
    Then the output should contain:
      """
      Dependency 'reset' was not found. Please make sure it is in your Berksfile, and then run `berks install` to download and install the missing dependencies.
      """
    And the exit status should be "DependencyNotFound"

  Scenario: specifying multiple cookbooks to upload
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'oops', '3.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf (= 2.0.0)
        fake (= 1.0.0)
        oops (= 3.0.0)

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
        oops (3.0.0)
      """
    When I successfully run `berks upload fake ekaf`
    Then the Chef Server should have the cookbooks:
      | fake |
      | ekaf |
    And the Chef Server should not have the cookbooks:
      | oops |

  Scenario: uploading a filter does not change the lockfile
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I run `berks upload --only take_me`
    Then the file "Berksfile.lock" should contain:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """

  Scenario: uploading a single groups of demands with the --only flag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I successfully run `berks upload --only take_me`
    Then the Chef Server should have the cookbooks:
      | fake | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | ekaf | 2.0.0 |

  Scenario: uploading multiple groups of demands with the --only flag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I successfully run `berks upload --only take_me not_me`
    And the Chef Server should have the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |

  Scenario: skipping a single group to upload with the --except flag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I successfully run `berks upload --except not_me`
    And the Chef Server should have the cookbooks:
      | fake | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | ekaf | 2.0.0 |

  Scenario: skipping multiple groups with the --except flag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        ekaf
        fake

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I successfully run `berks upload --except take_me not_me`
    And the Chef Server should not have the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |

  Scenario: specifying cookbooks with transitive dependencies in a group
    Given the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | ekaf | 2.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      group :rockstars do
        cookbook 'reset', '3.4.5'
      end

      group :losers do
        cookbook 'seth', '1.0.0'
      end
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        reset (= 3.4.5)

      GRAPH
        ekaf (2.0.0)
        fake (1.0.0)
          ekaf (= 2.0.0)
        reset (3.4.5)
          fake (= 1.0.0)
      """
    When I successfully run `berks upload --only rockstars`
    Then the Chef Server should have the cookbooks:
      | reset | 3.4.5 |
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
    And the Chef Server should not have the cookbooks:
      | seth | 1.0.0 |

  Scenario: attempting to upload an invalid cookbook
    Given a cookbook named "cookbook with spaces"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'cookbook with spaces', path: './cookbook with spaces'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        cookbook with spaces
          path: ./cookbook with spaces

      GRAPH
        cookbook with spaces (0.0.0)
      """
    When I run `berks upload`
    Then the output should contain:
      """
      The cookbook 'cookbook with spaces' has invalid filenames:
      """
    And the exit status should be "InvalidCookbookFiles"

  Scenario: With unicode characters
    Given a cookbook named "fake"
    And I cd to "fake"
    And I write to "README.md" with:
      """
      Jamié Wiñsor
      赛斯瓦戈
      Μιψηαελ Ιωευ
      جوستين كامبل
      """
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
    When I successfully run `berks upload fake`
    Then the output should contain:
      """
      Uploaded fake (0.0.0)
      """

  Scenario: When the cookbook already exist
    And the Chef Server has frozen cookbooks:
      | fake  | 1.0.0 |
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
      """
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Skipping fake (1.0.0) (frozen)
      """

  Scenario: When the cookbook already exist and is a metadata location
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "Berksfile" with:
      """
      metadata
      """
    And I cd to "fake"
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (0.0.0)
      """
    And the Chef Server has frozen cookbooks:
      | fake | 0.0.0 |
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Skipping fake (0.0.0) (frozen)
      """

  Scenario: When the syntax check is skipped
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "recipes/default.rb" with:
      """
      Totally not valid Ruby syntax
      """
    And the cookbook "fake" has the file "templates/default/file.erb" with:
      """
      <% for %>
      """
    And the cookbook "fake" has the file "recipes/template.rb" with:
      """
      template "/tmp/wadus" do
        source "file.erb"
      end
      """
    And the cookbook "fake" has the file "Berksfile" with:
      """
      source 'https://supermarket.chef.io'
      metadata
      """
    And the cookbook "fake" has the file "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake
          path: .
          metadata: true

      GRAPH
        fake (0.0.0)
      """
    And I cd to "fake"
    When I successfully run `berks upload --skip-syntax-check`
    Then the Chef Server should have the cookbooks:
      | fake | 0.0.0 |
