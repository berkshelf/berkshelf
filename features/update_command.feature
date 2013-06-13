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
    Then the output should warn about the old lockfile format
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"b2714a4f9bdf500cb20267067160a0b3c1d8404c",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0",
            "constraint":"~> 0.1"
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
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0",
            "constraint":"~> 0.1"
          },
          "hostsfile":{
            "locked_version":"1.0.1",
            "constraint":"= 1.0.1"
          }
        }
      }
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"69b2e00e970d2bb6a9b1d09aeb3e6a17ef3df955",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.2.0",
            "constraint":"~> 0.1"
          },
          "hostsfile":{
            "locked_version":"1.0.1",
            "constraint":"~> 1.0.0"
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
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0",
            "constraint":"~> 0.1"
          },
          "hostsfile":{
            "locked_version":"1.0.0",
            "constraint":"~> 1.0.0"
          }
        }
      }
      """
    And I successfully run `berks update berkshelf-cookbook-fixture`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"69b2e00e970d2bb6a9b1d09aeb3e6a17ef3df955",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.2.0",
            "constraint":"~> 0.1"
          },
          "hostsfile":{
            "locked_version":"1.0.0",
            "constraint":"~> 1.0.0"
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
<<<<<<< HEAD
        "dependencies":{
=======
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
>>>>>>> 5b9bbf6... Revert e84b189
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.1.0",
            "constraint":"~> 0.1"
          }
        }
      }
      """
    When I run `berks update non-existent-cookbook`
    Then the output should contain:
      """
      Could not find cookbook(s) 'non-existent-cookbook' in any of the configured dependencies. Is it in your Berksfile?
      """
    And the CLI should exit with the status code for error "CookbookNotFound"
