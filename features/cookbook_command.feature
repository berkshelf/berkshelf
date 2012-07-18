Feature: cookbook command
  As a Cookbook author  
  I want a way to quickly generate a Cookbook skeleton that contains supporting Berkshelf files
  So I can quickly and automatically generate a Cookbook containing Berkshelf supporting files or other common supporting files

  @wip
  Scenario: creating a new cookbook without the path option
    When I run the cookbook command to create "sparkle_motion"
    Then I should have the cookbook "sparkle_motion"
    And the cookbook "sparkle_motion" should have the following files:
      | Berksfile  |
      | chefignore |
    And the file "Berksfile" in the cookbook "sparkle_motion" should contain:
      """
      metadata
      """
