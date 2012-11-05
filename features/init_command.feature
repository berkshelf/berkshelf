Feature: initialize command
  As a Cookbook author
  I want a way to quickly prepare a Cookbook on my local disk with Berkshelf files
  So that I can resolve my Cookbook's dependencies with Berkshelf

  Scenario: initializing a path containing a cookbook
    Given a cookbook named "sparkle_motion"
    When I run the init command with the cookbook "sparkle_motion" as the target
    Then the cookbook "sparkle_motion" should have the following files:
      | Berksfile  |
      | chefignore |
    And the file "Berksfile" in the cookbook "sparkle_motion" should contain:
      """
      metadata
      """
    And the output should contain "Successfully initialized"
    And the exit status should be 0

  Scenario: initializing a path that does not contain a cookbook
    Given a directory named "not_a_cookbook"
    When I run the init command with the directory "not_a_cookbook" as the target
    Then the directory "not_a_cookbook" should have the following files:
      | Berksfile |
    And the directory "not_a_cookbook" should not have the following files:
      | chefignore |
    And the file "Berksfile" in the directory "not_a_cookbook" should not contain:
      """
      metadata
      """
    And the output should contain "Successfully initialized"
    And the exit status should be 0

  Scenario: initializing with no value given for target
    When I run the init command with no value for the target
    Then the output should contain "Successfully initialized"
    And the current directory should have the following files:
      | Berksfile |
    And the current directory should not have the following files:
      | chefignore |
    And the exit status should be 0
