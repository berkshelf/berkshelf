Feature: Evaluating a Berksfile
  Scenario: Containing pure Ruby
    Given I write to "Berksfile" with:
      """
      source 'https://supermarket.chef.io'

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
    And the exit status should be "BerksfileReadError"

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
    And the exit status should be "BerksfileReadError"
