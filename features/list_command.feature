Feature: list command
  As a user with a Berksfile
  I want a way to show all my cookbooks and their versions without opening my Berksfile
  So that I can be more productive

  Scenario: Running the list command
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      cookbook 'hostsfile', '1.0.1'
      """
    When I successfully run `berks list`
    Then the output should contain:
      """
      Cookbooks installed by your Berksfile:
        * berkshelf-cookbook-fixture (1.0.0)
        * hostsfile (1.0.1)
      """
    And the exit status should be 0
