Feature: Uploading cookbooks to a Chef Server
  As a Berkshelf CLI user
  I need a way to upload cookbooks to a Chef server that I have installed into my Bookshelf
  So they are available to Chef clients

  @chef_server @slow_process
  Scenario: With no arguments
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      """
    And the Chef server does not have the cookbooks:
      | fake   | 1.0.0 |
      | ekaf   | 2.0.0 |
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading fake (1.0.0) to: 'http://localhost:4000/'
      Uploading ekaf (2.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | fake   | 1.0.0 |
      | ekaf   | 2.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: With a path location in the Berksfile
    Given a cookbook named "fake"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', path: './fake'
      """
    And the Chef server does not have the cookbooks:
      | fake | 0.0.0 |
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading fake (0.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | fake | 0.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: With a git location in the Berksfile
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', ref: 'v0.1.0'
      """
    And the Chef server does not have the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    When I successfully run `berks upload`
    Then the output should contain:
      """
      Uploading berkshelf-cookbook-fixture (0.1.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With a single cookbook
    Given the cookbook store has the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
    And the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | ~> 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'reset', '3.4.5'
      """
    And the Chef server does not have the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
      | reset | 3.4.5 |
    When I successfully run `berks upload reset`
    Then the output should contain:
      """
      Uploading reset (3.4.5) to: 'http://localhost:4000/'
      Uploading fake (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | reset | 3.4.5 |
      | fake  | 1.0.0 |
    And the Chef server should not have the cookbooks:
      | ekaf  | 2.0.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With multiple cookbooks
    Given the cookbook store has the cookbooks:
      | ntp  | 1.0.0 |
      | vim  | 1.0.0 |
      | apt  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      cookbook 'ntp', '1.0.0'
      cookbook 'vim', '1.0.0'
      cookbook 'apt', '1.0.0'
      """
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
      | apt |
    When I successfully run `berks upload ntp vim`
    Then the output should contain:
      """
      Uploading ntp (1.0.0) to: 'http://localhost:4000/'
      Uploading vim (1.0.0) to: 'http://localhost:4000/'
      """
    And the output should not contain:
      """
      Uploading apt (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | ntp |
      | vim |
    And the Chef server should not have the cookbooks:
      | apt |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With the --only flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    And the Chef server does not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    When I successfully run `berks upload --only group_a`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:4000/'
      """
    And the output should not contain:
      """
      Uploading system (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | core | 1.0.0 |
    And the Chef server should not have the cookbooks:
      | system | 1.0.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With the --only flag specifying multiple groups
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    And the Chef server does not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    When I successfully run `berks upload --only group_a group_b`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:4000/'
      Uploading system (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With the --except flag
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    And the Chef server does not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    When I successfully run `berks upload --except group_b`
    Then the output should contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:4000/'
      """
    And the output should not contain:
      """
      Uploading system (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | core | 1.0.0 |
    And the Chef server should not have the cookbooks:
      | system | 1.0.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: With the --except flag specifying multiple groups
    Given the cookbook store has the cookbooks:
      | core    | 1.0.0 |
      | system  | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :group_a do
        cookbook 'core', '1.0.0'
      end

      group :group_b do
        cookbook 'system', '1.0.0'
      end
      """
    And the Chef server does not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    When I successfully run `berks upload --except group_a group_b`
    Then the output should not contain:
      """
      Uploading core (1.0.0) to: 'http://localhost:4000/'
      Uploading system (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should not have the cookbooks:
      | core   | 1.0.0 |
      | system | 1.0.0 |
    And the exit status should be 0

  Scenario: With an invalid cookbook
    Given a cookbook named "cookbook with spaces"
    And I write to "Berksfile" with:
      """
      cookbook 'cookbook with spaces', path: './cookbook with spaces'
      """
    When I run `berks upload`
    Then the output should contain:
      """
      The cookbook 'cookbook with spaces' has invalid filenames:
      """
    And the CLI should exit with the status code for error "InvalidCookbookFiles"

    @chef_server @slow_process
  Scenario: With the --skip-dependencies flag
    Given the cookbook store has the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
    And the cookbook store contains a cookbook "reset" "3.4.5" with dependencies:
      | fake | ~> 1.0.0 |
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      cookbook 'ekaf', '2.0.0'
      cookbook 'reset', '3.4.5'
      """
    And the Chef server does not have the cookbooks:
      | fake  | 1.0.0 |
      | ekaf  | 2.0.0 |
      | reset | 3.4.5 |
    When I successfully run `berks upload reset -D`
    Then the output should contain:
      """
      Uploading reset (3.4.5) to: 'http://localhost:4000/'
      Uploading fake (1.0.0) to: 'http://localhost:4000/'
      """
    And the Chef server should have the cookbooks:
      | reset | 3.4.5 |
      | fake  | 1.0.0 |
    And the Chef server should not have the cookbooks:
      | ekaf  | 2.0.0 |
    And the exit status should be 0

  @focus
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
      site :opscode
      metadata
      """
    When I cd to "fake"
    And I successfully run `berks upload fake`
    Then the output should contain:
      """
      Uploading fake (0.0.0)
      """
    And the exit status should be 0
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
      site :opscode

      metadata
      """
    And I cd to "fake"
    When I successfully run `berks upload --skip-syntax-check`
    Then the output should contain:
      """
      Using fake (0.0.0) from metadata
      Uploading fake (0.0.0) to: 'http://localhost:4000/'
      """
