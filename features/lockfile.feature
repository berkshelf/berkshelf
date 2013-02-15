Feature: Berksfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile
  So when I share my repository, all other developers get the same versions that I did when I installed.

  Scenario: Writing the Berksfile.lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '1.1.8'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
          "ntp":{
            "constraint":"= 1.1.8",
            "locked_version":"1.1.8"
          }
        }
      }
      """

  Scenario: Installing a cookbook with dependencies
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'database', '1.3.12'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"4efd21c0060d2a827a9258a72fa38c78fbd06d1a",
      "sources":{
        "database":{
          "constraint":"= 1.3.12",
          "locked_version":"1.3.12"
        },
        "mysql":{
          "constraint":">= 1.3.0",
          "locked_version":"2.1.2"
        },
        "openssl":{
          "constraint":">= 0.0.0",
          "locked_version":"1.0.0"
        },
        "build-essential":{
          "constraint":">= 0.0.0",
          "locked_version":"1.3.4"
        },
        "postgresql":{
          "constraint":">= 1.0.0",
          "locked_version":"2.2.2"
        },
        "aws":{
          "constraint":">= 0.0.0",
          "locked_version":"0.100.6"
        },
        "xfs":{
          "constraint":">= 0.0.0",
          "locked_version":"1.1.0"
        }
      }
    }
    """

  Scenario: Writing the Berksfile.lock with a pessimistic lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '~> 1.1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sha":"f11aa63004577ab13f1476c16a35e2e3ff9266aa",
        "sources":{
          "ntp":{
            "constraint":"~> 1.1.0",
            "locked_version":"1.1.8"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"7403c97a9321beb8060dde3fdc8702ad1b623f4b",
        "sources":{
          "ntp":{
            "constraint":"~> 1.1.0",
            "locked_version":"1.1.8"
          }
        }
      }
      """

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
      "sources":{
        "ntp":{
          "constraint":"~> 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """
  When I successfully run `berks update ntp`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
      "sources":{
        "ntp":{
          "constraint":"~> 1.3.0",
          "locked_version":"1.3.2"
        }
      }
    }
    """

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
      "sources":{
        "ntp":{
          "constraint":"= 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """
  When I successfully run `berks update ntp`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
      "sources":{
        "ntp":{
          "constraint":"= 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a git location
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'hostsfile', git: 'git://github.com/sethvargo-cookbooks/hostsfile.git', ref: 'c65010d'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha": "9536a7a09fc3be98aaa5728465525935916c9c7f",
      "sources":{
        "hostsfile":{
          "git":"git://github.com/sethvargo-cookbooks/hostsfile.git",
          "ref":"c65010d",
          "locked_version":"0.2.5"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a git location
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'hostsfile', github: 'sethvargo-cookbooks/hostsfile', ref: 'c65010d'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha": "16523c4b800eef9964d354b7f2d217b2de1d2d75",
      "sources":{
        "hostsfile":{
          "git":"git://github.com/sethvargo-cookbooks/hostsfile.git",
          "ref":"c65010d",
          "locked_version":"0.2.5"
        }
      }
    }
    """
