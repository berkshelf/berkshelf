Feature: cookbook creation with a config file
  As a Cookbook author  
  I want to quickly generate a cookbook with my own customizations
  So that I don't have to spend time modifying the default generated output each time

  Scenario: creating a new cookbook using a Berkshelf config
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrant": {
        "vm": {
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
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.network :hostonly, "12.34.56.78" |
      | config.vm.network :bridged |
      | config.vm.forward_port 12345, 54321 |
    And the exit status should be 0

  Scenario: creating a new cookbook using a partial Berkshelf config
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
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then the resulting "sparkle_motion" Vagrantfile should contain:
      | config.vm.forward_port 12345, 54321 |
    And the exit status should be 0

  Scenario: creating a new cookbook using an invalid Berkshelf config
    Given I have a Berkshelf config file containing:
    """
    {
      "vagrantz": {
        "vmz": null
      },
      "wat": "wat"
    }
    """
    When I run the cookbook command to create "sparkle_motion"
    Then the output should contain "Invalid configuration"
    And the CLI should exit with the status code for error "InvalidConfiguration"

  Scenario: creating a new cookbook when no Berkshelf config exists
    Given I do not have a Berkshelf config file
    When I run the cookbook command to create "sparkle_motion" with options:
      | --vagrant |
    Then the exit status should be 0
