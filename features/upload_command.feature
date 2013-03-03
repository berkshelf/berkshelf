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
  Scenario: explicitly specifying multiple cookbooks to upload
    Given I write to "Berksfile" with:
      """
      cookbook "ntp"
      cookbook "vim"
      cookbook "apt"
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
      | apt |
    When I run `berks upload ntp vim`
    Then the output should contain "Uploading ntp"
    And the output should contain "Uploading vim"
    And the output should not contain "Uploading apt"
    And the Chef server should have the cookbooks:
      | ntp |
      | vim |
    And the Chef server should not have the cookbooks:
      | apt |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: uploading a single group of cookbooks with the --only flag
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "ntp"
      end

      group :system do
        cookbook "vim"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
    When I run `berks upload --only core`
    Then the output should contain "Uploading ntp"
    And the output should not contain "Uploading vim"
    And the Chef server should have the cookbooks:
      | ntp |
    And the Chef server should not have the cookbooks:
      | vim |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: uploading multiple groups of cookbooks with the --only flag
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "ntp"
      end

      group :system do
        cookbook "vim"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
    When I run `berks upload --only core system`
    Then the output should contain "Uploading ntp"
    And the output should contain "Uploading vim"
    And the Chef server should have the cookbooks:
      | ntp |
      | vim |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: skip uploading one group of cookbooks with the --except flag
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "ntp"
      end

      group :system do
        cookbook "vim"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
    When I run `berks upload --except core`
    Then the output should not contain "Uploading ntp"
    And the output should contain "Uploading vim"
    And the Chef server should not have the cookbooks:
      | ntp |
    And the Chef server should have the cookbooks:
      | vim |
    And the exit status should be 0

  @chef_server @slow_process
  Scenario: skip uploading multiple groups of cookbooks with the --except flag
    Given I write to "Berksfile" with:
      """
      group :core do
        cookbook "ntp"
      end

      group :system do
        cookbook "vim"
      end
      """
    And I successfully run `berks install`
    And the Chef server does not have the cookbooks:
      | ntp |
      | vim |
    When I run `berks upload --except core system`
    Then the output should not contain "Uploading ntp"
    And the output should not contain "Uploading vim"
    And the Chef server should not have the cookbooks:
      | ntp |
      | vim |
    And the exit status should be 0
