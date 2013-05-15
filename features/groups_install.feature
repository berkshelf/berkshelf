Feature: installing groups
  As a user
  I want to be able specify groups of cookbooks to include or exclude
  So I don't install cookbooks that are part of a group that I do not want to install

  Scenario: except groups
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'nginx', '= 0.101.2'
      end

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'

      group :takeme do
        cookbook 'hostsfile', '1.0.1'
      end
      """
    When I successfully run `berks install --except notme`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
      | hostsfile | 1.0.1 |
    And the cookbook store should not have the cookbooks:
      | nginx | 0.101.2 |
    And the exit status should be 0

  Scenario: only groups
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'nginx', '= 0.101.2'
      end

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'

      group :takeme do
        cookbook 'hostsfile', '1.0.1'
      end
      """
    When I successfully run `berks install --only takeme`
    Then the cookbook store should have the cookbooks:
      | berkshelf-cookbook-fixture | 1.0.0 |
    And the cookbook store should not have the cookbooks:
      | nginx     | 0.101.2 |
      | hostsfile | 1.0.1 |
    And the exit status should be 0

  Scenario: attempting to provide an only and except option
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'nginx', '= 0.101.2'
      end

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'

      group :takeme do
        cookbook 'hostsfile', '1.0.1'
      end
      """
    When I run `berks install --only takeme --except notme`
    Then the output should contain:
      """
      Cannot specify both :except and :only
      """
    And the CLI should exit with the status code for error "ArgumentError"
