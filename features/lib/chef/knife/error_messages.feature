Feature: Friendly error messages
  As a CLI user
  I want to have friendly human readable error messages
  So I can identify what went wrong without ambiguity

  Scenario: running without a Cookbookfile
    When I run `knife cookbook dependencies install`
    Then the output should contain "FATAL: There is no Cookbookfile in "
