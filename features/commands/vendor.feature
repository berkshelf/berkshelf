Feature: Vendoring cookbooks to a directory
  Background:
    * the Berkshelf API server's cache is empty
    * the Chef Server has cookbooks:
      | fake | 1.0.0 |
      | ekaf | 2.0.0 |
    * the Berkshelf API server's cache is up to date

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

  Scenario: vendoring a cookbook with transitive dependencies
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    And I write to "metadata.rb" with:
      """
      name 'bacon'
      version '1.0.0'

      depends 'fake'
      depends 'ekaf'
      """
    When I successfully run `berks vendor vendor`
    Then the directory "vendor/bacon" should contain version "1.0.0" of the "bacon" cookbook
    And the directory "vendor/fake" should contain version "1.0.0" of the "fake" cookbook
    And the directory "vendor/ekaf" should contain version "2.0.0" of the "ekaf" cookbook

  Scenario: vendoring a cookbook with transitive dependencies when a lockfile is present
    Given a cookbook named "bacon"
    And the cookbook "bacon" has the file "metadata.rb" with:
      """
      name 'bacon'
      version '1.0.0'

      depends 'fake'
      depends 'ekaf'
      """
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'bacon', path: './bacon'
      """
    And I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        bacon
          path: ./bacon

      GRAPH
        bacon (1.0.0)
          ekaf (>= 0.0.0)
          fake (>= 0.0.0)
        ekaf (2.0.0)
        fake (1.0.0)
      """
    When I successfully run `berks vendor vendor`
    Then the directory "vendor/bacon" should contain version "1.0.0" of the "bacon" cookbook
    And the directory "vendor/fake" should contain version "1.0.0" of the "fake" cookbook
    And the directory "vendor/ekaf" should contain version "2.0.0" of the "ekaf" cookbook

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
    And a directory named "cukebooks/fake/ponies"
    And a directory named "cukebooks/existing_cookbook"
    When I successfully run `berks vendor cukebooks`
    And the directory "cukebooks/fake" should contain version "1.0.0" of the "fake" cookbook
    And a directory named "cukebooks/fake/ponies" should not exist
    And a directory named "cukebooks/existing_cookbook" should not exist

  Scenario: vendoring into a nested directory
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake'
      """
    When I successfully run `berks vendor path/to/cukebooks`
    Then the directory "path/to/cukebooks/fake" should contain version "1.0.0" of the "fake" cookbook

