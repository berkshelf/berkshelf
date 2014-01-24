Feature: Appending -h or --help to a command
  Scenario Outline: Using various help switches
    Then the output from `<actual>` should be the same as `<expected>`
    Examples:
      | actual                | expected |
      | berks --help          | berks help |
      | berks -h              | berks help |
      | berks cookbook --help | berks help cookbook |
      | berks cookbook -h     | berks help cookbook |
      | berks shelf --help    | berks shelf help |
      | berks shelf -h        | berks shelf help |
