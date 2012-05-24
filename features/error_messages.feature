Feature: Friendly error messages
  As a CLI user
  I want to have friendly human readable error messages
  So I can identify what went wrong without ambiguity

  Scenario: when missing a cookbook
    Given I write to "Cookbookfile" with:
    """
    cookbook "doesntexist"
    """
    And I run the install command
    Then the output should contain:
    """
    Cookbook 'doesntexist' not found on the Opscode Community site.
    """
    And the CLI should exit with the status code for error "RemoteCookbookNotFound"
