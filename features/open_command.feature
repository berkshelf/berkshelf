Feature: open command
  As a user
  I want to be able to view the source of a cached cookbook
  So that I can troubleshoot bugs in my dependencies

  Scenario: Running berks open with no $EDITOR
    Given the environment variable EDITOR is nil
    And the environment variable BERKSHELF_EDITOR is nil
    And the environment variable VISUAL is nil
    When I run `berks open mysql` interactively
    Then the output should contain "To open a cookbook, set $EDITOR or $BERKSHELF_EDITOR"

  # For some reason, we need to spawn here
  @spawn
  Scenario: Running berks open with an $EDITOR
    Given the environment variable EDITOR is "ls"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    When I run `berks open fake` interactively
    Then the output should contain "metadata.rb"

  Scenario: Running berks open with a missing EDITOR
    Given the environment variable EDITOR is "wat"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    When I run `berks open fake` interactively
    Then the output should contain "Could not run `wat "
    And the CLI should exit with the status code for error "CommandUnsuccessful"

  Scenario: Running berks open when the cookbook does not exist
    Given the environment variable EDITOR is "ls"
    And an empty file named "Berksfile"
    When I run `berks open mysql` interactively
    Then the output should contain "Cookbook 'mysql' not found in any of the sources!"
    And the CLI should exit with the status code for error "CookbookNotFound"
