Feature: install cookbooks from a Cookbookfile
  As a user with a Cookbookfile
  I want to be able to run knife cookbook dependencies install to install my cookbooks
  So that I don't have to download my cookbooks and their dependencies manually

  Scenario: install cookbooks
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql"
      """
    When I run `knife cookbook dependencies install`
    Then the following directories should exist:
      | cookbooks/mysql   |
      | cookbooks/openssl |

  Scenario: install cookbooks with the alias
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql"
      """
    When I run `knife cookbook deps install`
    Then the following directories should exist:
      | cookbooks/mysql   |
      | cookbooks/openssl |

  Scenario: running install when current project is a cookbook and the 'metadata' is specified
    Given a cookbook named "sparkle_motion"
    And the cookbook "sparkle_motion" has the file "Cookbookfile" with:
      """
      metadata
      """
    When I cd to "sparkle_motion"
    And I run the install command
    Then the output should contain:
      """
      Using cookbook found in current directory as 'sparkle_motion'
      """
    And the exit status should be 0

  Scenario: running install with no Cookbookfile or Cookbookfile.lock
    Given I do not have a Cookbookfile
    And I do not have a Cookbookfile.lock
    When I run the install command
    Then the output should contain:
      """
      No Cookbookfile or Cookbookfile.lock found at:
      """
    And the CLI should exit with the status code for error "CookbookfileNotFound"

  Scenario: running install when the Cookbook is not found on the remote site
    Given I write to "Cookbookfile" with:
      """
      cookbook "doesntexist"
      """
    And I run the install command
    Then the output should contain:
      """
      Cookbook 'doesntexist' not found at site: http://cookbooks.opscode.com/api/v1/cookbooks
      """
    And the CLI should exit with the status code for error "DownloadFailure"
