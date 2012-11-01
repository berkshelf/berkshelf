Feature: configure command
  As CLI user of Berkshelf
  I want a command to generate a Berkshelf configuration file based on my input
  So I can quickly get up and running with the least amount of resistance

  Scenario: generating a new config file
    Given I do not have a Berkshelf config file
    When I run the "configure" command interactively
    And I type "https://api.opscode.com/organizations/vialstudios"
    And I type "reset"
    And I type "/Users/reset/.chef/reset.pem"
    And I type "Berkshelf-minimal"
    And I type "https://dl.dropbox.com/Berkshelf.box"
    Then the output should contain:
      """
      Config written to:
      """
    And the exit status should be 0
    And a Berkshelf config file should exist and contain:
      | vagrant.chef.chef_server_url        | https://api.opscode.com/organizations/vialstudios |
      | vagrant.chef.validation_client_name | reset                                             |
      | vagrant.chef.validation_key_path    | /Users/reset/.chef/reset.pem                      |
      | vagrant.vm.box                      | Berkshelf-minimal                                 |
      | vagrant.vm.box_url                  | https://dl.dropbox.com/Berkshelf.box              |
