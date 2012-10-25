Feature: config command
  As a Cookbook author  
  I want to quickly generate a Berkshelf config
  So I can easily tell which options are available to me

  Scenario: creating a new config
    Given I do not have a Berkshelf config file
    When I run the config command
    Then I should have a Berkshelf config file
    And the exit status should be 0
