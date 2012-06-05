Feature: update
  As a user
  I want a way to update the versions without clearing out the files I've downloaded
  So that I can update faster than a clean install

  Scenario: knife cookbook dependencies update
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql"
      """
    Given I write to "Cookbookfile.lock" with:
      """
      cookbook 'mysql', :locked_version => '0.0.1'
      cookbook 'openssl', :locked_version => '0.0.1'
      """
    When I run the update command
    Then the file "Cookbookfile.lock" should contain exactly:
      """
      cookbook 'mysql', :locked_version => '1.2.6'
      cookbook 'openssl', :locked_version => '1.0.0'
      cookbook 'windows', :locked_version => '1.3.0'
      cookbook 'chef_handler', :locked_version => '1.0.6'
      """
