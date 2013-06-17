Feature: Evaluating a Berksfile
  As a user with a Berksfile
  I want to evaluate things and see nice errors
  So I can identify my syntax errors and faults

  Scenario: Containing pure Ruby
    Given I write to "Berksfile" with:
      """
      if ENV['BACON']
        puts "If you don't got bacon..."
      else
        puts "No bacon :'("
      end
      """
    And the environment variable BACON is "1"
    When I successfully run `berks install`
    Then the output should contain:
      """
      If you don't got bacon...
      """
    And the exit status should be 0

  Scenario: Calling valid DSL methods:
    Given I write to "Berksfile" with:
      """
      site :opscode
      """
    When I successfully run `berks install`
    And the exit status should be 0

  Scenario: Containing methods I shouldn't be able to call
    Given I write to "Berksfile" with:
      """
      add_location(:foo)
      """
    When I run `berks install`
    Then the output should contain:
      """
      An error occurred while reading the Berksfile:

        undefined method `add_location' for
      """
    And the CLI should exit with the status code for error "BerksfileReadError"

  Scenario: Containing Ruby syntax errors
    Given I write to "Berksfile" with:
      """
      ptus "This is a ruby syntax error"
      """
    When I run `berks install`
    Then the output should contain:
      """
      An error occurred while reading the Berksfile:

        undefined method `ptus' for
      """
