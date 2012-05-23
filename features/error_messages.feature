Feature: Friendly error messages
  As a CLI user
  I want to have friendly human readable error messages
  So I can identify what went wrong without ambiguity

  Scenario: running without a Cookbookfile
    When I run `knife cookbook dependencies install`
    Then the output should contain "FATAL: There is no Cookbookfile in "

  Scenario: when missing a cookbook
    Given I write to "Cookbookfile" with:
    """
    cookbook "doesntexist"
    """
    When I run `knife cookbook dependencies install`
    Then the output should contain "FATAL: The cookbook doesntexist was not found on the Opscode Community site. Provide a git or path key for doesntexist if it is unpublished."
