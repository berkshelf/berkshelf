Feature: Uploading cookbooks to a Chef Server
  As a Berkshelf CLI user
  I need a way to upload cookbooks to a Chef Server that I have installed into my Bookshelf
  So they are available to Chef clients

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty
    And the cookbook store is empty

  Scenario: multiple cookbooks with no arguments
    Given the cookbook store has the cookbooks:
      | ruby   | 1.0.0 |
      | elixir | 2.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'ruby', '1.0.0'
      cookbook 'elixir', '2.0.0'
      """
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading ruby (1.0.0) to: 'http://localhost:26310/'
      Uploading elixir (2.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | ruby   | 1.0.0 |
      | elixir | 2.0.0 |

  Scenario: a cookbook with a path location
    Given a cookbook named "ruby"
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'ruby', path: './ruby'
      """
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading ruby (0.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | ruby | 0.0.0 |

  Scenario: a cookbook with a git location
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', ref: 'v0.1.0'
      """
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading berkshelf-cookbook-fixture (0.1.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |

  Scenario: specifying a single cookbook with dependencies
    Given the cookbook store has the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
    And the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | = 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'reset', '3.4.5'
      """
    When I successfully run `berks upload reset`
    Then the output should contain:
      """
      Uploading reset (3.4.5) to: 'http://localhost:26310/'
      Uploading fake (1.0.0) to: 'http://localhost:26310/'
      """
    And the output should not contain:
      """
      Uploading ekaf (2.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | reset | 3.4.5 |
      | fake  | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | ekaf  | 2.0.0 |

  Scenario: specifying a dependency not defined in the Berksfile
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"
      """
    When I run `berks upload reset`
    Then the output should contain:
      """
      Could not find cookbook(s) 'reset' in any of the configured dependencies. Is it in your Berksfile?
      """
    And the exit status should be "DependencyNotFound"

  Scenario: specifying multiple cookbooks to upload
    Given the cookbook store has the cookbooks:
      | ntp  | 1.0.0 |
      | vim  | 1.0.0 |
      | apt  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'apt', '1.0.0'
      cookbook 'ntp', '1.0.0'
      cookbook 'vim', '1.0.0'
      """
    When I successfully run `berks upload ntp vim`
    Then the output should contain:
      """
      Uploading ntp (1.0.0) to: 'http://localhost:26310/'
      Uploading vim (1.0.0) to: 'http://localhost:26310/'
      """
    And the output should not contain:
      """
      Uploading apt (1.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | ntp |
      | vim |
    And the Chef Server should not have the cookbooks:
      | apt |

  Scenario: uploading a single groups of demands with the --only flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    When I successfully run `berks upload --only group_a`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:26310/'
      """
    And the output should not contain:
      """
      Uploading system (1.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | core | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | system | 1.0.0 |

  Scenario: uploading multiple groups of demands with the --only flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    When I successfully run `berks upload --only group_a group_b`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:26310/'
      Uploading system (1.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |

  Scenario: skipping a single group to upload with the --except flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    When I successfully run `berks upload --except group_b`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:26310/'
      """
    And the output should not contain:
      """
      Uploading system (1.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should have the cookbooks:
      | core | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | system | 1.0.0 |

  Scenario: skipping multiple groups with the --except flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    When I successfully run `berks upload --except group_a group_b`
    Then the output should not contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:26310/'
      Uploading system (1.0.0) to: 'http://localhost:26310/'
      """
    And the Chef Server should not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |

  Scenario: attempting to upload an invalid cookbook
    Given a cookbook named "cookbook with spaces"
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'cookbook with spaces', path: './cookbook with spaces'
      """
    When I run `berks upload`
    Then the output should contain:
      """
      The cookbook 'cookbook with spaces' has invalid filenames:
      """
    And the exit status should be "InvalidCookbookFiles"

  Scenario: With unicode characters
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "README.md" with:
      """
      Jamié Wiñsor
      赛斯瓦戈
      Μιψηαελ Ιωευ
      جوستين كامبل
      """
    And the cookbook "fake" has the file "Berksfile" with:
      """
      source "http://localhost:26210"

      metadata
      """
    When I cd to "fake"
    And I successfully run `berks upload fake`
    Then the output should contain:
      """
      Uploading fake (0.0.0)
      """

  Scenario: When the cookbook already exist
    Given the cookbook store has the cookbooks:
      | fake  | 1.0.0 |
    And the Chef Server has frozen cookbooks:
      | fake  | 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Skipping fake (1.0.0) (already uploaded)
      """
    And the output should contain:
      """
      Skipped uploading some cookbooks because they already existed on the remote server. Re-run with the `--force` flag to force overwrite these cookbooks:

        * fake (1.0.0)
      """
    And the exit status should be 0

  Scenario: When the cookbook already exist and is a metadata location
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "Berksfile" with:
      """
      metadata
      """
    When I cd to "fake"
    And the Chef Server has frozen cookbooks:
      | fake  | 0.0.0 |
    When I run `berks upload`
    Then the output should contain:
      """
      The cookbook fake (0.0.0) already exists and is frozen on the Chef Server. Use the --force option to override.
      """
    And the exit status should be "FrozenCookbook"
