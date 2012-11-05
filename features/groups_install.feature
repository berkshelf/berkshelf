Feature: installing groups
  As a user
  I want to be able specify groups of cookbooks to include or exclude
  So I don't install cookbooks that are part of a group that I do not want to install

  Scenario: except groups
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook "nginx", "= 0.101.2"
      end

      cookbook "artifact", "= 0.10.0"

      group :takeme do
        cookbook "ntp", "= 1.1.8"
      end
      """
    When I run the install command with flags:
      | --except notme |
    Then the cookbook store should have the cookbooks:
      | artifact | 0.10.0 |
      | ntp      | 1.1.8 |
    And the cookbook store should not have the cookbooks:
      | nginx | 0.101.2 |

  Scenario: only groups
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook "nginx", "= 0.101.2"
      end

      cookbook "artifact", "= 0.10.0"

      group :takeme do
        cookbook "ntp", "= 1.1.8"
      end
      """
    When I run the install command with flags:
      | --only takeme |
    Then the cookbook store should have the cookbooks:
      | ntp | 1.1.8 |
    And the cookbook store should not have the cookbooks:
      | nginx    | 0.101.2 |
      | artifact | 0.10.0 |

  Scenario: attempting to provide an only and except option
    Given I write to "Berksfile" with:
      """
      group :notme do
        cookbook "nginx", "= 0.101.2"
      end

      cookbook "artifact", "= 0.10.0"

      group :takeme do
        cookbook "ntp", "= 1.1.8"
      end
      """
    When I run the install command with flags:
      | --only takeme --except notme |
    Then the output should contain:
      """
      Cannot specify both :except and :only
      """
    And the CLI should exit with the status code for error "ArgumentError"
