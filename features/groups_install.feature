Feature: Installing specific groups
  As a user
  I want to be able specify groups of cookbooks to include or exclude
  So I don't install cookbooks that are part of a group that I do not want to install

  Background:
    Given the cookbook store has the cookbooks:
      | default | 1.0.0 |
      | notme   | 1.0.0 |
      | takeme  | 1.0.0 |
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'default', '1.0.0'
      cookbook 'notme',   '1.0.0', group: :notme
      cookbook 'takeme',  '1.0.0', group: :takeme
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "notme": { "locked_version": "1.0.0"},
          "takeme": { "locked_version": "1.0.0"},
          "default": { "locked_version": "1.0.0"}
        }
      }
      """


  Scenario: when the --except option
    When I successfully run `berks install --except notme`
    Then the output should contain:
      """
      Using default (1.0.0)
      Using takeme (1.0.0)
      """
    And the output should not contain "Using notme (1.0.0)"


  Scenario: with the --only option
    When I successfully run `berks install --only takeme`
    Then the output should contain "Using takeme (1.0.0)"
    Then the output should not contain "Using notme (1.0.0)"
    Then the output should not contain "Using default (1.0.0)"


  Scenario: Attempting to provide an only and except option
    When I run `berks install --only takeme --except notme`
    Then the output should contain "Cannot specify both :except and :only"
    And the exit status should be "ArgumentError"
