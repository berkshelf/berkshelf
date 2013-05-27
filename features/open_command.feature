Feature: Opening the contents of a cookbook defined by a Berksfile
  As a user
  I want to be able to view the source of a cached cookbook
  So that I can troubleshoot bugs in my dependencies

  Scenario: When the editor is `ls`
    Given the environment variable EDITOR is "ls"
    And I write to "Berksfile" with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    When I successfully run `berks open fake`
    Then the output should contain "metadata.rb"

  Scenario: When no editor is set
    Given the environment variable EDITOR is nil
    And the environment variable BERKSHELF_EDITOR is nil
    And the environment variable VISUAL is nil
    When I run `berks open mysql` interactively
    Then the output should contain "To open a cookbook, set $EDITOR or $BERKSHELF_EDITOR"

  Scenario: When the editor does not exist
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

  Scenario: When the cookbook does not exist
    Given the environment variable EDITOR is "ls"
    And an empty file named "Berksfile"
    When I run `berks open mysql` interactively
    Then the output should contain "Cookbook 'mysql' not found in any of the sources!"
    And the CLI should exit with the status code for error "CookbookNotFound"
