Feature: cookbook command
  As a Cookbook author
  I want a way to quickly generate a Cookbook skeleton that contains supporting Berkshelf files
  So I can quickly and automatically generate a Cookbook containing Berkshelf supporting files or other common supporting files

  Scenario: creating a new cookbook skeleton
    When I run the cookbook command to create "sparkle_motion"
    Then I should have a new cookbook skeleton "sparkle_motion"
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with Foodcritic support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --foodcritic |
    Then I should have a new cookbook skeleton "sparkle_motion" with Foodcritic support
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with Foodcritic support without Foodcritic installed
    When I run the cookbook command to create "sparkle_motion" with options:
      | --foodcritic |
    Then I should have a new cookbook skeleton "sparkle_motion" with Foodcritic support
    And the output should contain "This cookbook was generated with --foodcritic, however, foodcritic is not installed.\nTo make use of --foodcritic: gem install foodcritic"
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with SCMVersion support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --scmversion |
    Then I should have a new cookbook skeleton "sparkle_motion" with SCMVersion support
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton with SCMVersion support without thor-scmversion installed
    When I run the cookbook command to create "sparkle_motion" with options:
      | --scmversion |
    Then I should have a new cookbook skeleton "sparkle_motion" with SCMVersion support
    And the output should contain "This cookbook was generated with --scmversion, however, thor-scmversion is not installed.\nTo make use of --scmversion: gem install thor-scmversion"
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton without Bundler support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --no-bundler |
    Then I should have a new cookbook skeleton "sparkle_motion" without Bundler support
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton without Git support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --skip-git |
    Then I should have a new cookbook skeleton "sparkle_motion" without Git support
    And the exit status should be 0

  Scenario: creating a new cookbook skeleton without Vagrant support
    When I run the cookbook command to create "sparkle_motion" with options:
      | --skip-vagrant |
    Then I should have a new cookbook skeleton "sparkle_motion" without Vagrant support
    And the exit status should be 0
