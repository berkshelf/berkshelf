Feature: Updating a cookbook defined by a Berksfile
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: With the old lockfile format
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    And I write to "Berksfile.lock" with:
      """
      cookbook 'berkshelf-cookbook-fixture', :locked_version => '0.1.0'
      """
    When I successfully run `berks update`
    Then the output should contain "You are using the old lockfile format. Attempting to convert..."
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0"
          }
        }
      }
      """

  Scenario: Without a cookbook specified
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
      | berkshelf-cookbook-fixture | 0.2.0 |
      | hostsfile                  | 1.0.1 |
    And I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      cookbook 'hostsfile', '~> 1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0"
          },
          "hostsfile":{
            "locked_version":"1.0.1"
          }
        }
      }
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.2.0"
          },
          "hostsfile":{
            "locked_version":"1.0.1"
          }
        }
      }
      """

  Scenario: With a single cookbook specified
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
      | berkshelf-cookbook-fixture | 0.2.0 |
      | hostsfile                  | 1.0.1 |
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      cookbook 'hostsfile', '~> 1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0"
          },
          "hostsfile":{
            "locked_version":"1.0.0"
          }
        }
      }
      """
    And I successfully run `berks update berkshelf-cookbook-fixture`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.2.0"
          },
          "hostsfile":{
            "locked_version":"1.0.0"
          }
        }
      }
      """

  Scenario: With a cookbook that does not exist
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture | 0.1.0 |
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0"
          }
        }
      }
      """
    When I run `berks update non-existent-cookbook`
    Then the output should contain:
      """
      Could not find cookbooks 'non-existent-cookbook' in any of the sources. Is it in your Berksfile?
      """
    And the CLI should exit with the status code for error "CookbookNotFound"
