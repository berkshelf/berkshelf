Feature: berks init
  Scenario: initializing a path containing a cookbook
    Given a cookbook named "sparkle_motion"
    When I successfully run `berks init sparkle_motion`
    Then the cookbook "sparkle_motion" should have the following files:
      | Berksfile  |
      | chefignore |
    And the file "Berksfile" in the cookbook "sparkle_motion" should contain:
      """
      metadata
      """
    And the output should contain "Successfully initialized"

  Scenario: initializing a path that does not contain a cookbook
    Given a directory named "not_a_cookbook"
    When I run `berks init not_a_cookbook`
    And the exit status should be "NotACookbook"

  Scenario: initializing with no value given for target
    Given I write to "metadata.rb" with:
      """
      name 'sparkle_motion'
      """
    When I successfully run `berks init`
    Then the output should contain "Successfully initialized"
    And a file named "Berksfile" should exist
    And a file named "chefignore" should exist
