@focus
Feature: cookbook command w/ Vagrant
  As a Cookbook author
  I want a way to quickly generate a Cookbook skeleton that includes Vagrant support
  So that I can customize it the way I'm used to

  Scenario: creating a new cookbook skeleton with Vagrant support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then I should have a new cookbook skeleton "sparkle_motion" with Vagrant support
    And the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.host_name = "sparkle_motion-berkshelf" |
      | config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal" |
      | config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box" |

    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with a different Vagrant box name
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant --vagrant-vm-box base |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      """
      config.vm.box = "base"
      """
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with a different Vagrant box name
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant --vagrant-vm-box-url 'http://files.vagrantup.com/lucid32.box' |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      """
      config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
      """
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with a different Vagrant host name
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant --vagrant-vm-host-name sparkle_motion |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      """
      config.vm.host_name = "sparkle_motion"
      """
    And the exit status should be 0

  Scenario: creating a new cookbook using a Berkshelf config
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant_vm_network_hostonly": "12.34.56.78",
      "vagrant_vm_network_bridged": true,
      "vagrant_vm_forward_port": { "12345": "54321" }
    }
    """
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.network :hostonly, "12.34.56.78" |
      | config.vm.network :bridged |
      | config.vm.forward_port 12345, 54321 |
    And the exit status should be 0

  Scenario: creating a new cookbook when no Berkshelf config exists
    Given I do not have a Berkshelf config file
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then the exit status should be 0
