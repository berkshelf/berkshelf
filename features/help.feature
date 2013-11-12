Feature: Appending -h or --help to a command
  Scenario: A top-level command
    When I successfully run `berks --help`
    Then the output should contain:
      """
      Usage:
          berks [OPTIONS] SUBCOMMAND [ARG] ...
      """


  Scenario: A subcommand
    When I successfully run `berks shelf --help`
    Then the output should contain:
      """
      Usage:
          berks shelf [OPTIONS] SUBCOMMAND [ARG] ...
      """
