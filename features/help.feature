Feature: Appending -h or --help to a command
  As a user
  I want to be able to run berkshelf like my existing Unix CLI tools
  So that I don't have remember thor's stupid argument ordering

  Scenario: Specifying the --help option
    Given I successfully run `berks --help`
    Then the output should be the same as `berks help`

  Scenario: Specifying the -h option
    Given I successfully run `berks -h`
    Then the output should be the same as `berks help`

  Scenario: Specifying the --help option to a sub-command
    Given I successfully run `berks cookbook --help`
    Then the output should be the same as `berks help cookbook`

  Scenario: Specifying the -h option to a sub-command
    Given I successfully run `berks cookbook -h`
    Then the output should be the same as `berks help cookbook`