Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  @slow_process
  Scenario: updating with the old lockfile format
    Given I write to "Berksfile" with:
      """
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
        "sha":"4882acee1fd114467076d9d5d3c8afe19dc2c316",
        "sources":{
          "apt":{
            "locked_version":"1.8.2",
            "constraint":"~> 1.8.0"
          }
        }
      }
      """

  @slow_process
  Scenario: Updating all cookbooks
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "0.10.0"
      cookbook "build-essential", "~> 1.1.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
          "ntp":{
            "locked_version":"0.10.0",
            "constraint":"= 0.10.0"
          }
        }
      }
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"b1d1fb7e34f6a3a3a71282d311e4d23e4c929aaf",
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

  @slow_process
  Scenario: Updating a single cookbook
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "0.10.0"
      cookbook "build-essential", "~> 1.3.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
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
    And I successfully run `berks install`
    When I successfully run `berks update build-essential`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"2bbadebb88837d537ca5bc29e5765b97c7d5f5a3",
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

  @slow_process
  Scenario: Update a cookbook that doesn't exist
    Given I write to "Berksfile" with:
      """
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
