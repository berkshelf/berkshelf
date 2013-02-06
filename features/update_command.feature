Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

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
        "sources":[
          {
            "name":"ntp",
            "locked_version":"0.10.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """
    When I successfully run `berks update`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"b1d1fb7e34f6a3a3a71282d311e4d23e4c929aaf",
        "sources":[
          {
            "name":"artifact",
            "locked_version":"0.10.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          },
          {
            "name":"build-essential",
            "locked_version":"1.1.2",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
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
        "sources":[
          {
            "name":"artifact",
            "locked_version":"0.10.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          },
          {
            "name":"build-essential",
            "locked_version":"1.3.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """
    And I successfully run `berks install`
    When I successfully run `berks update build-essential`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"2bbadebb88837d537ca5bc29e5765b97c7d5f5a3",
        "sources":[
          {
            "name":"artifact",
            "locked_version":"0.10.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          },
          {
            "name":"build-essential",
            "locked_version":"1.3.4",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
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
        "sources":[
          {
            "name":"ntp",
            "locked_version":"0.10.0",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """
    When I run `berks update non-existent-cookbook`
    Then the output should contain:
      """
      Could not find cookbooks 'non-existent-cookbook' in any of the sources. Is it in your Berksfile?
      """
    And the CLI should exit with the status code for error "CookbookNotFound"
