Feature: Berksfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile
  So when I share my repository, all other developers get the same versions that I did when I installed.

  @slow_process
  Scenario: Writing the Berksfile.lock
    Given I write to "Berksfile" with:
      """
      cookbook 'ntp', '1.1.8'
      """
    When I run the install command
    Then a file named "Berksfile.lock" should exist in the current directory
    And the file "Berksfile.lock" should contain in the current directory:
      """
      cookbook 'ntp', :locked_version => '1.1.8'
      """
