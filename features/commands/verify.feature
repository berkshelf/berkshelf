Feature: berks verify
  Scenario: running verify when there is no Lockfile present
    Given a cookbook named "sparkle_motion"
    And I cd to "sparkle_motion"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    And I run `berks verify`
    Then the output should contain:
      """
      Lockfile not found! Run `berks install` to create the lockfile.
      """
    And the exit status should be "LockfileNotFound"

  Scenario: running verify when there is a valid Lockfile present
    Given a cookbook named "sparkle_motion"
    And I cd to "sparkle_motion"
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      metadata
      """
    When I successfully run `berks install`
    And I successfully run `berks verify`
    Then the output should contain:
      """
      Verifying (1) cookbook(s)...
      Verified.
      """
