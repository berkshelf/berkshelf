Feature: Reading a Berkshelf configuration file
  As a Cookbook author
  I want to quickly generate a cookbook with my own customizations
  So that I don't have to spend time modifying the default generated output each time

  Scenario: Missing a Berkshelf configuration file
    Given I do not have a Berkshelf config file
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal" |
      | config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box" |
    And the exit status should be 0

  Scenario: Using a Berkshelf configuration file
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "vm": {
          "box": "my_box",
          "box_url": "http://files.vagrantup.com/lucid64.box",
          "forward_port": {
            "12345": "54321"
          },
          "network": {
            "bridged": true,
            "hostonly": "12.34.56.78"
          }
        }
      }
    }
    """
    When I successfully run `berks cookbook sparkle_motion`
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.box = "my_box" |
      | config.vm.box_url = "http://files.vagrantup.com/lucid64.box" |
      | config.vm.network :forwarded_port, guest: 12345, host: 54321 |
      | config.vm.network :private_network, ip: "12.34.56.78" |
      | config.vm.network :public_network |
    And the exit status should be 0

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
    And the exit status should be 0

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
    And the CLI should exit with the status code for error "InvalidConfiguration"

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
      | chef.chef_server_url        = "localhost:4000"      |
      | chef.validation_client_name = "my_client-validator" |
      | chef.validation_key_path    = "/a/b/c/my_client-validator.pem" |
    Then the exit status should be 0
