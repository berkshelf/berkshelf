Feature: package command
  As a user
  I want to be able to package a cookbook
  So that I can use it outside of Berkshelf

  Scenario: Running the package command
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '~> 1.0.0'
      """
    When I successfully run `berks package berkshelf-cookbook-fixture`
    Then a file named "berkshelf-cookbook-fixture.tar.gz" should exist
    And the output should contain:
      """
      Package saved to
      """
    And the exit status should be 0

  Scenario: Running the package command with the --output option
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '~> 1.0.0'
      """
    When I successfully run `berks package berkshelf-cookbook-fixture --output foo/bar`
    Then a file named "foo/bar/berkshelf-cookbook-fixture.tar.gz" should exist
    And the exit status should be 0

  Scenario: Running the package command with an installed cookbook name
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '~> 1.0.0'
      """
    When I run `berks package non-existent`
    Then a file named "non-existent.tar.gz" should not exist
    And the output should contain:
      """
      Cookbook 'non-existent' is not in your Berksfile
      """
    And the CLI should exit with the status code for error "CookbookNotFound"
