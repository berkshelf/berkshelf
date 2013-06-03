Feature: Wrapping an existing cookbook
  As a Cookbook author
  I want a way to quickly generate a cookbook that leverages the functionality of another cookbook
  So that I can write more maintainble cookbooks

  Scenario: With the default options
    When I successfully run `berks wrap sparkle_motion`
    Then I should have a new cookbook skeleton "chef-sparkle_motion"
    And the exit status should be 0
