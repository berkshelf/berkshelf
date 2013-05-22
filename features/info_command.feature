Feature: info command
  As a user
  I want to be able to view the metadata information of a cached cookbook
  So that I can troubleshoot bugs or satisfy my own curiosity

  Scenario: Running the info command
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks info berkshelf-cookbook-fixture`
    Then the output should contain:
      """
              Name: berkshelf-cookbook-fixture
           Version: 1.0.0
       Description: Installs/Configures berkshelf-cookbook-fixture
            Author: Michael D. Ivey
             Email: ivey@gweezlebur.com
           License: All rights reserved
      """

  Scenario: Running the info command with a version flag
    Given I write to "Berksfile" with:
      """
      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks info berkshelf-cookbook-fixture --version 1.0.0`
    Then the output should contain:
      """
              Name: berkshelf-cookbook-fixture
           Version: 1.0.0
       Description: Installs/Configures berkshelf-cookbook-fixture
            Author: Michael D. Ivey
             Email: ivey@gweezlebur.com
           License: All rights reserved
      """

  Scenario: Running the info command for a cookbook that is not defined in the Berksfile
    Given an empty file named "Berksfile"
    When I run `berks info berkshelf-cookbook-fixture`
    Then the output should contain "Cookbook 'berkshelf-cookbook-fixture' is not installed by your Berksfile"
    And the CLI should exit with the status code for error "CookbookNotFound"
