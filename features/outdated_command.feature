Feature: Displaying outdated cookbooks
  As a user
  I want to know what cookbooks are outdated before I run update
  So that I can decide whether to update everything at once

  Scenario: Running berks outdated with no version constraints
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture'
      """
    When I successfully run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      All cookbooks up to date
      """

  Scenario: Running berks outdated with satisfied version constraints
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '>= 0.1'
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      All cookbooks up to date
      """

  Scenario: Running berks outdated with unsatisfied version constraints
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    When I run `berks outdated`
    Then the output should contain:
      """
      Listing outdated cookbooks with newer versions available...
      """
    And the output should contain:
      """
      Cookbook 'berkshelf-cookbook-fixture (~> 0.1)' is outdated
      """
