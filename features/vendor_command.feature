Feature: Vendoring cookbooks to a directory
  As a CLI user
  I want a command to vendor cookbooks into a directory
  So they are structured similar to a Chef Repository

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server has cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
    And the Berkshelf API server's cache is up to date

  Scenario: successfully vendoring a Berksfile with multiple cookbook demands
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      cookbook 'ekaf'
      """
    When I successfully run `berks vendor cukebooks`
    Then the directory "cukebooks/fake" should contain version "1.0.0" of the "fake" cookbook
    And the directory "cukebooks/ekaf" should contain version "2.0.0" of the "ekaf" cookbook


  Scenario: attempting to vendor when no Berksfile is present
    When I run `berks vendor cukebooks`
    Then the exit status should be "BerksfileNotFound"


  Scenario: vendoring a Berksfile with a metadata demand
    Given a cookbook named "fake"
    And I cd to "fake"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    When I successfully run `berks vendor cukebooks`
    And the directory "cukebooks/fake" should contain version "0.0.0" of the "fake" cookbook


  Scenario: vendoring without an explicit path to vendor into
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    When I successfully run `berks vendor`
    And the directory "berks-cookbooks/fake" should contain version "1.0.0" of the "fake" cookbook


  Scenario: vendoring to a directory that already exists
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    And a directory named "cukebooks"
    When I run `berks vendor cukebooks`
    And the exit status should be "VendorError"
