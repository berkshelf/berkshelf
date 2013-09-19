Feature: Uploading cookbooks to a Chef Server
  As a Berkshelf CLI user
  I need a way to upload cookbooks to a Chef Server that I have installed into my Bookshelf
  So they are available to Chef clients

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
      | oops | 3.0.0 |

  Scenario: multiple cookbooks with no arguments
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
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
    When I successfully run `berks upload`
    Then the Chef Server should have the cookbooks:
      | fake | 0.0.0 |


  Scenario: specifying a single cookbook with dependencies
    Given the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | = 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'reset', '3.4.5'
      """
    When I successfully run `berks upload reset`
    Then the Chef Server should have the cookbooks:
      | reset | 3.4.5 |
      | fake  | 1.0.0 |
    And the Chef Server should not have the cookbooks:
      | ekaf  | 2.0.0 |


  Scenario: specifying a dependency not defined in the Berksfile
    Given I have a Berksfile pointing at the local Berkshelf API
    When I run `berks upload reset`
    Then the output should contain:
      """
      Could not find cookbook(s) 'reset' in any of the configured dependencies. Is it in your Berksfile?
      """
    And the exit status should be "DependencyNotFound"


  Scenario: specifying multiple cookbooks to upload
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'oops', '3.0.0'
      """
    When I successfully run `berks upload fake ekaf`
    Then the Chef Server should have the cookbooks:
      | fake |
      | ekaf |
    And the Chef Server should not have the cookbooks:
      | oops |


  Scenario: uploading a single groups of demands with the --only flag
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', group: :take_me
      cookbook 'ekaf', group: :not_me
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
    When I successfully run `berks upload --except take_me not_me`
    And the Chef Server should not have the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |


  Scenario: attempting to upload an invalid cookbook
    Given a cookbook named "cookbook with spaces"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
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
    When I successfully run `berks upload fake`
    Then the output should contain:
      """
      Uploading fake (0.0.0)
      """


  Scenario: When the cookbook already exist
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


  Scenario: When the cookbook already exist and is a metadata location
    Given a cookbook named "fake"
    And the cookbook "fake" has the file "Berksfile" with:
      """
      metadata
      """
    And the Chef Server has frozen cookbooks:
      | fake  | 0.0.0 |
    And I cd to "fake"
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Skipping fake (0.0.0) (already uploaded)
      Skipped uploading some cookbooks because they already existed on the remote server. Re-run with the `--force` flag to force overwrite these cookbooks:

        * fake (0.0.0)
      """
