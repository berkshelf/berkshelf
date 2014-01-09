Feature: berks cookbook
  Scenario: With the default options
    When I successfully run `berks cookbook sparkle_motion`
    Then I should have a new cookbook skeleton "sparkle_motion"

  Scenario Outline: With various options
    When I successfully run `berks cookbook sparkle_motion --<option>`
    Then I should have a new cookbook skeleton "sparkle_motion" with <feature> support
  Examples:
    | option            | feature         |
    | foodcritic        | Foodcritic      |
    | chef-minitest     | Chef-Minitest   |
    | scmversion        | SCMVersion      |
    | no-bundler        | no Bundler      |
    # Disable testing of skip git until Test Kitchen supports the skip_git flag in its generator
    # https://github.com/opscode/test-kitchen/issues/141
    # | skip-git          | no Git          |
    | skip-vagrant      | no Vagrant      |
    | skip-test-kitchen | no Test Kitchen |

  Scenario Outline: When a required supporting gem is not installed
    Given the gem "<gem>" is not installed
    When I successfully run `berks cookbook sparkle_motion --<option>`
    Then I should have a new cookbook skeleton "sparkle_motion" with <feature> support
    And the output should contain a warning to suggest supporting the option "<option>" by installing "<gem>"
  Examples:
    | option     | feature    | gem             |
    | foodcritic | Foodcritic | foodcritic      |
    | scmversion | SCMVersion | thor-scmversion |

  Scenario: When bundler is not installed
    Given the gem "bundler" is not installed
    When I successfully run `berks cookbook sparkle_motion`
    Then I should have a new cookbook skeleton "sparkle_motion"
    And the output should contain a warning to suggest supporting the default for "bundler" by installing "bundler"
