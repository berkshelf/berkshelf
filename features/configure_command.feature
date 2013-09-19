@spawn
Feature: Configuring Berkshelf via the command line
  As CLI user of Berkshelf
  I want a command to generate a Berkshelf configuration file based on my input
  So I can quickly get up and running with the least amount of resistance

  Background:
    Given I do not have a Berkshelf config

  Scenario: Using custom values
    When I run `berks configure` interactively
    And I type "https://api.opscode.com/organizations/vialstudios"
    And I type "node_name"
    And I type "client_key"
    And I type "reset"
    And I type "/Users/reset/.chef/reset.pem"
    And I type "Berkshelf-minimal"
    And I type "https://dl.dropbox.com/Berkshelf.box"
    Then the output should contain:
      """
      Config written to:
      """
    And a Berkshelf config file should exist and contain:
      | chef.chef_server_url        | https://api.opscode.com/organizations/vialstudios |
      | chef.validation_client_name | reset                                             |
      | chef.node_name              | node_name                                         |
      | chef.client_key             | client_key                                        |
      | chef.validation_key_path    | /Users/reset/.chef/reset.pem                      |
      | vagrant.vm.box              | Berkshelf-minimal                                 |
      | vagrant.vm.box_url          | https://dl.dropbox.com/Berkshelf.box              |


  Scenario: Accepting the default values
    Given I do not have a Chef config
    When I run `berks configure` interactively
    And I type ""
    And I type ""
    And I type ""
    And I type ""
    And I type ""
    And I type ""
    And I type ""
    Then the output should contain:
      """
      Config written to:
      """
    And a Berkshelf config file should exist and contain:
      | chef.chef_server_url        | http://localhost:4000               |
      | chef.validation_client_name | chef-validator                      |
      | chef.client_key             | /etc/chef/client.pem                |
      | chef.validation_key_path    | /etc/chef/validation.pem            |
      | vagrant.vm.box              | opscode_ubuntu-12.04_provisionerless |
      | vagrant.vm.box_url          | https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box |
      | vagrant.omnibus.enabled     | BOOLEAN[true] |
      | vagrant.omnibus.version     | latest |

  Scenario: Creating a Berkshelf configuration file when one already exists
    Given I already have a Berkshelf config file
    When I run `berks configure`
    Then the output should contain:
      """
      A configuration file already exists. Re-run with the --force flag if you wish to overwrite it.
      """
    And the exit status should be "ConfigExists"

  Scenario Outline: Using the --path option
    When I run `berks configure --path <path>` interactively
    And I type "https://api.opscode.com/organizations/vialstudios"
    And I type "node_name"
    And I type "client_key"
    And I type "reset"
    And I type "/Users/reset/.chef/reset.pem"
    And I type "Berkshelf-minimal"
    And I type "https://dl.dropbox.com/Berkshelf.box"
    Then the output should contain:
      """
      Config written to:
      """
    And a Berkshelf config file should exist at "<path>" and contain:
      | chef.chef_server_url        | https://api.opscode.com/organizations/vialstudios |
      | chef.validation_client_name | reset                                             |
      | chef.node_name              | node_name                                         |
      | chef.client_key             | client_key                                        |
      | chef.validation_key_path    | /Users/reset/.chef/reset.pem                      |
      | vagrant.vm.box              | Berkshelf-minimal                                 |
      | vagrant.vm.box_url          | https://dl.dropbox.com/Berkshelf.box              |

    Examples:
      | path                   |
      | .berkshelf/config.json |
      | berkshelf/config.json  |
