Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: knife berkshelf update
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "0.10.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      cookbook 'artifact', :locked_version => '0.1.0'
      """
    When I run `berks update`
    Then the file "Berksfile.lock" should contain exactly:
      """
      cookbook 'artifact', :locked_version => '0.10.0'
      """

  Scenario: knife berkshelf update a single cookbook
    Given I write to "Berksfile" with:
      """
      cookbook "artifact", "0.10.0"
      cookbook "build-essential", "~> 1.1.0"
      """
    Given I write to "Berksfile.lock" with:
      """
      cookbook 'artifact', :locked_version => '0.10.0'
      cookbook 'build-essential', :locked_version => '1.1.0'
      """
    When I run `berks update build-essential`
    Then the file "Berksfile.lock" should contain exactly:
      """
      cookbook 'artifact', :locked_version => '0.10.0'
      cookbook 'build-essential', :locked_version => '1.1.2'
      """
