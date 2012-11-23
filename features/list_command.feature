Feature: list command
  As a user with a Berksfile
  I want a way to show all my cookbooks and their versions without opening my Berksfile
  So that I can be more productive

  @slow_process
  Scenario: Running the list command
    Given I write to "Berksfile" with:
      """
      cookbook "build-essential", "1.2.0"
      cookbook "chef-client", "1.2.0"
      cookbook "mysql", "1.2.4"
      """
    And I successfully run `berks install`
    When I run `berks list`
    Then the output should contain:
      """
      Cookbooks installed by your Berksfile:
        * build-essential (1.2.0)
        * chef-client (1.2.0)
        * mysql (1.2.4)
        * openssl (1.0.0)
      """
    And the exit status should be 0
