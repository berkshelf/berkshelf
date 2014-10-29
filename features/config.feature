Feature: Reading a Berkshelf configuration file
  Scenario: Missing a Berkshelf configuration file
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.omnibus.chef_version = 'latest' |
      | config.vm.box = 'chef/ubuntu-14.04' |

  Scenario: Using a Berkshelf configuration file that sets the vagrant-omnibus plugin chef version
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "omnibus": {
          "version": "11.4.4"
        },
        "vm": {
          "box": "chef/ubuntu-14.04",
          "forward_port": {
            "12345": "54321"
          }
        }
      }
    }
    """
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.omnibus.chef_version = '11.4.4' |
      | config.vm.box = 'chef/ubuntu-14.04' |
      | config.vm.network :forwarded_port, guest: 12345, host: 54321 |
      | config.vm.network :private_network, type: 'dhcp' |
    And the exit status should be 0

  Scenario: Using a Berkshelf configuration file that sets the vagrant-omnibus plugin chef version to latest
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "omnibus": {
          "version": "latest"
        },
        "vm": {
          "box": "chef/ubuntu-14.04",
          "forward_port": {
            "12345": "54321"
          }
        }
      }
    }
    """
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.omnibus.chef_version = 'latest' |
      | config.vm.box = 'chef/ubuntu-14.04' |
      | config.vm.network :forwarded_port, guest: 12345, host: 54321 |
      | config.vm.network :private_network, type: 'dhcp' |

  Scenario: Using a partial Berkshelf configuration file
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "vm": {
          "forward_port": {
            "12345": "54321"
          }
        }
      }
    }
    """
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.network :forwarded_port, guest: 12345, host: 54321 |

  Scenario: Using an invalid Berkshelf configuration file
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "vm": {
          "box": 1
        }
      }
    }
    """
    When I run `berks cookbook sparkle_motion`
    Then the output should contain "Invalid configuration"
    And the output should contain "vagrant.vm.box Expected attribute: 'vagrant.vm.box' to be a type of: 'String'"
    And the exit status should be "InvalidConfiguration"

  Scenario: Using a Berkshelf configuration file with Chef configuration information
    Given I have a Berkshelf config file containing:
    """
    {
      "chef": {
        "chef_server_url": "localhost:4000",
        "validation_client_name": "my_client-validator",
        "validation_key_path": "/a/b/c/my_client-validator.pem"
      },
      "vagrant": {
        "vm": {
          "provision": "chef_client"
        }
      }
    }
    """
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.provision :chef_client                    |
      | chef.chef_server_url        = 'localhost:4000'      |
      | chef.validation_client_name = 'my_client-validator' |
      | chef.validation_key_path    = '/a/b/c/my_client-validator.pem' |
