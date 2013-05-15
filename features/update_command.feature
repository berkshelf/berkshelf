Feature: update command
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: updating with the old lockfile format
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    Given I write to "Berksfile.lock" with:
      """
      cookbook 'berkshelf-cookbook-fixture', :locked_version => '0.1.0'
      """
    When I successfully run `berks update`
    Then the output should contain "You are using the old lockfile format. Attempting to convert..."
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"b2714a4f9bdf500cb20267067160a0b3c1d8404c",
        "sources":{
          "berkshelf-cookbook-fixture":{
            "locked_version":"0.2.0",
            "constraint":"~> 0.1"
          }
        }
      }
      """

  Scenario: Updating all cookbooks
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      cookbook 'hostsfile', '~> 1.0.0'
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
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
        "sha":"69b2e00e970d2bb6a9b1d09aeb3e6a17ef3df955",
        "sources":{
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

  Scenario: Updating a single cookbook
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      cookbook 'hostsfile', '~> 1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
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
        "sha":"69b2e00e970d2bb6a9b1d09aeb3e6a17ef3df955",
        "sources":{
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

  Scenario: Update a cookbook that doesn't exist
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'berkshelf-cookbook-fixture', '~> 0.1'
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
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
      Could not find cookbooks 'non-existent-cookbook' in any of the sources. Is it in your Berksfile?
      """
    And the CLI should exit with the status code for error "CookbookNotFound"
