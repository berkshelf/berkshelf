Feature: Berksfile default locations
  As a Berkshelf user
  I want to be able to define default locations in my Berksfile
  So I can set the precedence of where cookbook sources are downloaded from or define an alternate location for all
  cookbook sources to attempt to retrieve from

  @chef_server
  Scenario: with a default chef_api(1) and site(2) location with a cookbook source that is satisfied by the chef_api(1) location
    Given I write to "Berksfile" with:
      """
      chef_api :config
      site :opscode

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And the Chef server has cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from chef_api:
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: with a default chef_api(1) and site(2) location with a cookbook source that is not satisfied by the chef_api(1) location
    Given I write to "Berksfile" with:
      """
      chef_api :config
      site :opscode

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And the Chef server does not have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: with a default site(1) and chef_api(2) location with a cookbook source that is satisfied by the site(1) location
    Given I write to "Berksfile" with:
      """
      site :opscode
      chef_api :config

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And the Chef server has cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I run the install command
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: with a default chef_api(1) location and a cookbook source that is satisfied by the chef_api(1) location but has an explicit location set
    Given I write to "Berksfile" with:
      """
      chef_api :config

      cookbook 'berkshelf-cookbook-fixture', '1.0.0', site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the Chef server has cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I run the install command
    Then the output should contain:
      """
      Installing berkshelf-cookbook-fixture (1.0.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
      """
    And the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the exit status should be 0

  @chef_server
  Scenario: with a defualt chef_api(1) location and a cookbook source that is not satisfied by it
    Given I write to "Berksfile" with:
      """
      chef_api :config

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    And the Chef server does not have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    When I run the install command
    Then the output should contain:
      """
      Cookbook 'berkshelf-cookbook-fixture' not found in any of the default locations
      """
    And the CLI should exit with the status code for error "CookbookNotFound"

  Scenario: with two duplicate locations definitions
    Given I write to "Berksfile" with:
      """
      site 'http://cookbooks.opscode.com/api/v1/cookbooks'
      site 'http://cookbooks.opscode.com/api/v1/cookbooks'

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I run the install command
    Then the output should contain:
      """
      A default 'site' location with the value 'http://cookbooks.opscode.com/api/v1/cookbooks' is already defined
      """
    And the CLI should exit with the status code for error "DuplicateLocationDefined"

  Scenario: with two locations of the same type but different values
    Given I write to "Berksfile" with:
      """
      site 'http://cookbooks.opscode.com/api/v1/cookbooks'
      site 'http://cookbooks.opscode.com/api/v2/cookbooks'

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I run the install command
    Then the exit status should be 0
