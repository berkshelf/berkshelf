Feature: Installing specific groups
  As a user
  I want to be able specify groups of cookbooks to include or exclude
  So I don't install cookbooks that are part of a group that I do not want to install

  Scenario: Using the --except option
    Given the cookbook store has the cookbooks:
      | default  | 1.0.0 |
      | takeme   | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'notme', '1.0.0'
      end

      cookbook 'default', '1.0.0'

      group :takeme do
        cookbook 'takeme', '1.0.0'
      end
      """
    When I successfully run `berks install --except notme`
    Then the output should contain:
      """
      Using default (1.0.0)
      Using takeme (1.0.0)
      """
    And the output should not contain "Using notme (1.0.0)"
    And the exit status should be 0

  Scenario: Using the --except option with a lockfile
    Given the cookbook store has the cookbooks:
      | default  | 1.0.0 |
      | takeme   | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'notme', '1.0.0'
      end

      cookbook 'default', '1.0.0'

      group :takeme do
        cookbook 'takeme', '1.0.0'
      end
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sources": {
          "notme": { "locked_version": "1.0.0"},
          "takeme": { "locked_version": "1.0.0"},
          "default": { "locked_version": "1.0.0"}
        }
      }
      """
    When I successfully run `berks install --except notme`
    Then the output should contain:
      """
      Using default (1.0.0)
      Using takeme (1.0.0)
      """
    And the output should not contain "Using notme (1.0.0)"
    And the exit status should be 0

  Scenario: Using the --only option
    Given the cookbook store has the cookbooks:
      | takeme   | 1.0.0 |
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook 'notme', '1.0.0'
      end

      cookbook 'default', '1.0.0'

      group :takeme do
        cookbook 'takeme', '1.0.0'
      end
      """
    When I successfully run `berks install --only takeme`
    Then the output should contain "Using takeme (1.0.0)"
    Then the output should not contain "Using notme (1.0.0)"
    Then the output should not contain "Using default (1.0.0)"
    And the exit status should be 0

  Scenario: Attempting to provide an only and except option
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
