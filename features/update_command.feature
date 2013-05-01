Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: updating with the old lockfile format
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook "apt", "~> 1.8.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      cookbook 'apt', :locked_version => '1.8.2'
      """
    When I successfully run `berks update`
    Then the output should contain "You are using the old lockfile format. Attempting to convert..."
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"d8e287b0c8138a31b664a912217b06ffd4cfde88",
        "sources":{
          "apt":{
            "locked_version":"1.8.4",
            "constraint":"~> 1.8.0"
          }
        }
      }
      """

  Scenario: Updating all cookbooks
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook "artifact", "0.10.0"
      cookbook "build-essential", "~> 1.1.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
          "artifact":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
          },
          "build-essential":{
            "locked_version":"1.1.0",
            "constraint":"~> 1.1.0"
          }
        }
      }
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"9d10199aa2652f9e965149c4346db20c78e97553",
        "sources":{
          "artifact":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
          },
          "build-essential":{
            "locked_version":"1.1.2",
            "constraint":"~> 1.1.0"
          }
        }
      }
      """

  Scenario: Updating a single cookbook
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook "artifact", "0.10.0"
      cookbook "build-essential", "~> 1.3.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"62352d72ce9bcb0b3f4af65962b64805b9540f6d",
        "sources":{
          "artifact":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
          },
          "build-essential":{
            "locked_version":"1.3.0",
            "constraint":"~> 1.3.0"
          }
        }
      }
      """
    And I successfully run `berks update build-essential`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"62352d72ce9bcb0b3f4af65962b64805b9540f6d",
        "sources":{
          "artifact":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
          },
          "build-essential":{
            "locked_version":"1.3.4",
            "constraint":"~> 1.3.0"
          }
        }
      }
      """

  Scenario: Update a cookbook that doesn't exist
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook "artifact", "0.10.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
          "artifact":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
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
