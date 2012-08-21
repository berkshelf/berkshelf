Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: knife berkshelf update
    Given I write to "Berksfile" with:
      """
      cookbook "mysql"
      """
    Given I write to "Berksfile.lock" with:
      """
      cookbook 'mysql', :locked_version => '0.0.1'
      cookbook 'openssl', :locked_version => '0.0.1'
      """
    When I run the update command
    Then the file "Berksfile.lock" should contain exactly:
      """
      cookbook 'mysql', :locked_version => '1.3.0'
      cookbook 'openssl', :locked_version => '1.0.0'
      cookbook 'windows', :locked_version => '1.3.2'
      cookbook 'chef_handler', :locked_version => '1.0.6'
      """
