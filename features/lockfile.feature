Feature: Berksfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile
  So when I share my repository, all other developers get the same versions that I did when I installed.

  @slow_process
  Scenario: Writing the Berksfile.lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '1.1.8'
      """
    When I successfully run `berks install`
    Then a file named "Berksfile.lock" should exist in the current directory
    And the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":[
          {
            "name":"ntp",
            "locked_version":"1.1.8",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """

  @slow_process
  Scenario: Writing the Berksfile.lock with a pessimistic lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '~> 1.1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sha":"7403c97a9321beb8060dde3fdc8702ad1b623f4b",
        "sources":[
          {
            "name":"ntp",
            "locked_version":"1.1.8",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """
    When I successfully run `berks install`
    Then a file named "Berksfile.lock" should exist in the current directory
    And the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"7403c97a9321beb8060dde3fdc8702ad1b623f4b",
        "sources":[
          {
            "name":"ntp",
            "locked_version":"1.1.8",
            "location":{
              "type":"site",
              "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
            }
          }
        ]
      }
      """

  @slow_process
  Scenario: Updating with a Berksfile.lock with pessimistic lock
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '~> 1.3.0'
    """
  And I write to "Berksfile.lock" with:
    """
    {
      "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
      "sources":[
        {
          "name":"ntp",
          "locked_version":"1.3.0",
          "location":{
            "type":"site",
            "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
          }
        }
      ]
    }
    """
  When I successfully run `berks update ntp`
  Then a file named "Berksfile.lock" should exist in the current directory
  And the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
      "sources":[
        {
          "name":"ntp",
          "locked_version":"1.3.2",
          "location":{
            "type":"site",
            "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
          }
        }
      ]
    }
    """

  @slow_process
  Scenario: Updating with a Berksfile.lock with hard lock
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '1.3.0'
    """
  And I write to "Berksfile.lock" with:
    """
    {
      "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
      "sources":[
        {
          "name":"ntp",
          "locked_version":"1.3.0",
          "location":{
            "type":"site",
            "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
          }
        }
      ]
    }
    """
  When I successfully run `berks update ntp`
  Then a file named "Berksfile.lock" should exist in the current directory
  And the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
      "sources":[
        {
          "name":"ntp",
          "locked_version":"1.3.0",
          "location":{
            "type":"site",
            "value":"http://cookbooks.opscode.com/api/v1/cookbooks"
          }
        }
      ]
    }
    """
