Feature: upload command
  As a Berkshelf CLI user
  I need a way to upload cookbooks to a Chef server that I have installed into my Bookshelf
  So they are available to Chef clients

  @no_run @chef_server
  Scenario: running the upload command when the Sources in the Berksfile are already installed
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And the Chef server does not have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And I run the install command
    When I run the upload command
    Then the output should not contain "Using mysql (1.2.4)"
    And the output should not contain "Using openssl (1.0.0)"
    And the output should contain "Uploading mysql (1.2.4) to:"
    And the output should contain "Uploading openssl (1.0.0) to:"
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: running the upload command when the Sources in the Berksfile have not been installed
    Given I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And the Chef server does not have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    When I run the upload command
    Then the output should contain "Installing mysql (1.2.4) from site:"
    And the output should contain "Installing openssl (1.0.0) from site:"
    And the output should contain "Uploading mysql (1.2.4) to:"
    And the output should contain "Uploading openssl (1.0.0) to:"
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: running the upload command with a Berksfile containing a source that has a path location
    Given a Berksfile with path location sources to fixtures:
      | example_cookbook | example_cookbook-0.5.0 |
    And the Chef server does not have the cookbooks:
      | example_cookbook | 0.5.0 |
    When I run the upload command
    Then the output should contain "Using example_cookbook (0.5.0) at path:"
    And the output should contain "Uploading example_cookbook (0.5.0) to:"
    And the Chef server should have the cookbooks:
      | example_cookbook | 0.5.0 |
    And the exit status should be 0

  @chef_server
  Scenario: running the upload command with a Berksfile containing a source that has a Git location
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", git: "git://github.com/RiotGames/artifact-cookbook.git", ref: "0.9.8"
      """
    And the Chef server does not have the cookbooks:
      | artifact | 0.9.8 |
    When I run the upload command
    Then the output should contain "Installing artifact (0.9.8) from git:"
    And the output should contain "Uploading artifact (0.9.8) to:"
    And the Chef server should have the cookbooks:
      | artifact | 0.9.8 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command for a single cookbook
    Given I write to "Berksfile" with:
      """
      cookbook "build-essential", "1.2.0"
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | mysql           | 1.2.4 |
      | openssl         | 1.0.0 |
      | build-essential | 1.2.0 |
    When I run `berks upload mysql`
    Then the output should contain "Uploading mysql (1.2.4)"
    And the output should contain "Uploading openssl (1.0.0)"
    And the output should not contain "Uploading build-essential (1.2.0)"
    And the Chef server should have the cookbooks:
      | mysql | 1.2.4 |
      | openssl | 1.0.0 |
    And the Chef server should not have the cookbooks:
      | build-essential | 1.2.0 |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command with multiple cookbooks
    Given I write to "Berksfile" with:
      """
      cookbook "build-essential"
      cookbook "chef-client"
      cookbook "database"
      cookbook "editor"
      cookbook "git"
      cookbook "known_host"
      cookbook "networking_basic"
      cookbook "vim"
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | build-essential  |
      | chef-client      |
      | database         |
      | editor           |
      | git              |
      | known_host       |
      | networking_basic |
      | vim              |
    When I run `berks upload build-essential chef-client database`
    Then the output should contain "Uploading build-essential"
    And the output should contain "Uploading chef-client"
    And the output should contain "Uploading database"
    And the output should not contain "Uploading editor"
    And the output should not contain "Uploading git"
    And the output should not contain "Uploading known_host"
    And the output should not contain "Uploading networking_basic"
    And the output should not contain "Uploading vim"
    And the Chef server should have the cookbooks:
      | build_essential |
      | chef-client     |
      | database        |
    And the Chef server should not have the cookbooks:
      | editor           |
      | git              |
      | known_host       |
      | networking_basic |
      | vim              |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command with the :only option
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "build-essential"
        cookbook "chef-client"
      end

      group :system do
        cookbook "database"
        cookbook "editor"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | build-essential  |
      | chef-client      |
      | database         |
      | editor           |
    When I run `berks upload --only core`
    Then the output should contain "Uploading build-essential"
    And the output should contain "Uploading chef-client"
    And the output should not contain "Uploading database"
    And the output should not contain "Uploading editor"
    And the Chef server should have the cookbooks:
      | build_essential |
      | chef-client     |
    And the Chef server should not have the cookbooks:
      | database |
      | editor   |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command with the :only option multiple
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "build-essential"
        cookbook "chef-client"
      end

      group :system do
        cookbook "database"
        cookbook "editor"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | build-essential  |
      | chef-client      |
      | database         |
      | editor           |
    When I run `berks upload --only core system`
    Then the output should contain "Uploading build-essential"
    And the output should contain "Uploading chef-client"
    And the output should contain "Uploading database"
    And the output should contain "Uploading editor"
    And the Chef server should have the cookbooks:
      | build_essential |
      | chef-client     |
      | database        |
      | editor          |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command with the :except option
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "build-essential"
        cookbook "chef-client"
      end

      group :system do
        cookbook "database"
        cookbook "editor"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | build-essential  |
      | chef-client      |
      | database         |
      | editor           |
    When I run `berks upload --except core`
    Then the output should not contain "Uploading build-essential"
    And the output should not contain "Uploading chef-client"
    And the output should contain "Uploading database"
    And the output should contain "Uploading editor"
    And the Chef server should not have the cookbooks:
      | build_essential |
      | chef-client     |
    And the Chef server should have the cookbooks:
      | database |
      | editor   |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: Running the upload command with the :except option multiple
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "build-essential"
        cookbook "chef-client"
      end

      group :system do
        cookbook "database"
        cookbook "editor"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | build-essential  |
      | chef-client      |
      | database         |
      | editor           |
    When I run `berks upload --except core system`
    Then the output should not contain "Uploading build-essential"
    And the output should not contain "Uploading chef-client"
    And the output should not contain "Uploading database"
    And the output should not contain "Uploading editor"
    And the Chef server should not have the cookbooks:
      | build_essential |
      | chef-client     |
      | database        |
      | editor          |
    And the exit status should be 0
