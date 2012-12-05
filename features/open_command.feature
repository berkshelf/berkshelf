Feature: open command
  As a user
  I want to be able to view the source of a cached cookbook
  So that I can troubleshoot bugs in my dependencies

  Scenario: Running berks open with no $EDITOR
    Given the environment variable EDITOR is nil
    And the cookbook store has the cookbooks:
      | mysql | 1.2.4 |
    When I run `berks open mysql`
    Then the output should contain "To open a cookbook, set $EDITOR or $BERKSHELF_EDITOR"

  Scenario: Running berks open with an $EDITOR
    Given the environment variable EDITOR is "ls"
    And the cookbook store has the cookbooks:
      | mysql | 1.2.4 |
    When I run `berks open mysql`
    Then the output should contain "metadata.rb"

  Scenario: Running berks open with a missing EDITOR
    Given the environment variable EDITOR is "wat"
    And the cookbook store has the cookbooks:
      | mysql | 1.2.4 |
    When I run `berks open mysql`
    Then the output should contain "Could not run `wat "
    And the CLI should exit with the status code for error "CommandUnsuccessful"

  Scenario: Running berks open when the cookbook does not exist
    Given the environment variable EDITOR is "ls"
    When I run `berks open mysql`
    Then the output should contain "Cookbook 'mysql' not found in any of the sources!"
    And the CLI should exit with the status code for error "CookbookNotFound"
