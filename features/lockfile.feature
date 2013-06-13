Feature: Creating and reading the Berkshelf lockfile
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile
  So when I share my repository, all other developers get the same versions that I did when I installed.

  Scenario: Writing the Berksfile.lock
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"80396ed07db133e0192593adebb360c27eed88c2",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "fake":{
            "constraint":"= 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Wiring the Berksfile.lock when a 1.0 lockfile is present
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      cookbook 'fake', :locked_version => '1.0.0'
      """
    When I successfully run `berks install`
    Then the output should warn about the old lockfile format
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "dependencies": {
          "fake": {
            "constraint": "= 1.0.0",
            "locked_version": "1.0.0"
          }
        }
      }
      """

  @focus
  Scenario: Wiring the Berksfile.lock when a 2.0 lockfile is present
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sources": {
          "fake": {
            "constraint": "= 1.0.0",
            "locked_version": "1.0.0"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the output should warn about the old lockfile format
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "dependencies": {
          "fake": {
            "constraint": "= 1.0.0",
            "locked_version": "1.0.0"
          }
        }
      }
      """

  Scenario: Writing the Berksfile.lock when an old lockfile is present and contains a full path
    Given a cookbook named "fake"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '0.0.0', path: './fake'
      """
    And I dynamically write to "Berksfile.lock" with:
      """
      cookbook 'fake', :locked_version => '0.0.0', path: '<%= File.expand_path('tmp/aruba/fake') %>'
      """
    When I successfully run `berks install`
    Then the output should warn about the old lockfile format
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"4b614de85168d72fda4b255fc31796b4c474c3fc",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "fake":{
            "constraint":"= 0.0.0",
            "path":"./fake"
          }
        }
      }
      """

  Scenario: Installing a cookbook with dependencies
    Given the cookbook store has the cookbooks:
      | dep | 1.0.0 |
    And the cookbook store contains a cookbook "fake" "1.0.0" with dependencies:
      | dep | ~> 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"80396ed07db133e0192593adebb360c27eed88c2",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "fake":{
            "constraint":"= 1.0.0",
            "locked_version":"1.0.0"
          },
          "dep":{
            "constraint":"~> 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Writing the Berksfile.lock with a pessimistic lock
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"e42f8e41a5e646bd86591c5b7ec25442736b87fd",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"~> 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"e42f8e41a5e646bd86591c5b7ec25442736b87fd",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"~> 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating with a Berksfile.lock with pessimistic lock
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.2.0 |
      | berkshelf-cookbook-fixture | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"~> 0.1",
            "locked_version":"0.1.0"
          }
        }
      }
      """
    When I successfully run `berks update berkshelf-cookbook-fixture`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"b2714a4f9bdf500cb20267067160a0b3c1d8404c",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"~> 0.1",
            "locked_version":"0.2.0"
          }
        }
      }
      """

  Scenario: Updating with a Berksfile.lock with hard lock
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"= 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """
    When I successfully run `berks update berkshelf-cookbook-fixture`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"c6438d7590f4d695d8abae83ff22586ba6d3a52e",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "constraint":"= 1.0.0",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock with a git location
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 919afa0c402089df23ebdf36637f12271b8a96b4 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', ref: '919afa0c4'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "b8e06c891c824b3e3481df024eb241e1c02572a6",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "git":"git://github.com/RiotGames/berkshelf-cookbook-fixture.git",
            "ref":"919afa0c402089df23ebdf36637f12271b8a96b4",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock with a git location and a branch
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | master |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', branch: 'master'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "310f95bb86ba76b47eef28abc621d0e8de19bbb6",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "git":"git://github.com/RiotGames/berkshelf-cookbook-fixture.git",
            "ref":"a97b9447cbd41a5fe58eee2026e48ccb503bd3bc",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock with a git location and a branch
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 70a527e17d91f01f031204562460ad1c17f972ee |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', git: 'git://github.com/RiotGames/berkshelf-cookbook-fixture.git', tag: 'v0.2.0'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "ade51e222f569cc299f34ec1100d321f3b230c36",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "git":"git://github.com/RiotGames/berkshelf-cookbook-fixture.git",
            "ref":"70a527e17d91f01f031204562460ad1c17f972ee",
            "locked_version":"0.2.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock with a GitHub location
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 919afa0c402089df23ebdf36637f12271b8a96b4 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', ref: '919afa0c4'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "3ac97aa503bcebb2b393410aebc176c3c5bed2d4",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "git":"git://github.com/RiotGames/berkshelf-cookbook-fixture.git",
            "ref":"919afa0c402089df23ebdf36637f12271b8a96b4",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock when a git location with :rel
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', github: 'RiotGames/berkshelf-cookbook-fixture', branch: 'rel', rel: 'cookbooks/berkshelf-cookbook-fixture'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "f0b5a9c0230a3ff384badb0c40af1058cde75bee",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "git":"git://github.com/RiotGames/berkshelf-cookbook-fixture.git",
            "ref":"93f5768b7d14df45e10d16c8bf6fe98ba3ff809a",
            "rel":"cookbooks/berkshelf-cookbook-fixture",
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: Updating a Berksfile.lock with a path location
    Given a cookbook named "fake"
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'fake', path: './fake'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha": "42a13f91f1ba19ce8c6776fe267e74510dee27ce",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "fake":{
            "path":"./fake"
          }
        }
      }
      """

  Scenario: Installing a Berksfile with a metadata location
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "Berksfile" with:
      """
      site :opscode
      metadata
      """
    When I cd to "fake"
    And I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "dependencies": {
          "fake": {
            "path": "."
          }
        }
      }
      """

  Scenario: Installing a Berksfile with a metadata location
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "Berksfile" with:
      """
      site :opscode
      metadata
      """
    And the cookbook "fake" has the file "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "fake": {
            "path": "."
          }
        }
      }
      """
    When I cd to "fake"
    And I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "dependencies": {
          "fake": {
            "path": "."
          }
        }
      }
      """
    And the exit status should be 0

  Scenario: Updating a Berksfile.lock with a different site location
  Given pending we have a reliable non-opscode site to test
  # Given I write to "Berksfile" with:
  #   """
  #   cookbook 'fake', site: 'example.com'
  #   """
  # When I successfully run `berks install`
  # Then the file "Berksfile.lock" should contain JSON:
  #   """
  #   {
<<<<<<< HEAD
  #     "dependencies":{
=======
  #     "sha": "3232c5ae6f54aee3efc5fdcfce69249a2526822b",
  #     "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
  #       "sudo":{
  #         "site":"opscode",
  #         "locked_version":"2.0.4"
  #       }
  #     }
  #   }
  #   """

  Scenario: Installing when the locked version is no longer satisfied
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And I successfully run `berks install`
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 1.3.0'
      """
    When I run `berks install`
    Then the output should contain:
      """
      Berkshelf could not find compatible versions for cookbook 'berkshelf-cookbook-fixture':
        In Berksfile:
          berkshelf-cookbook-fixture (~> 1.3.0)

        In Berksfile.lock:
          berkshelf-cookbook-fixture (1.0.0)

      Try running `berks update berkshelf-cookbook-fixture, which will try to find 'berkshelf-cookbook-fixture' matching '~> 1.3.0'
      """
    And the CLI should exit with the status code for error "OutdatedDependency"
