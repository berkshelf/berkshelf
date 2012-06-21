Feature: Berksfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile 
  So when I share my repository, all other developers get the same versions that I did when I installed.

  @slow_process
  Scenario: Writing the Berksfile.lock
    Given I write to "Berksfile" with:
      """
      cookbook 'ntp'
      cookbook 'mysql', git: 'https://github.com/opscode-cookbooks/mysql.git', :ref => '190c0c2267785b7b9b303369b8a64ed04364d5f9'
      """
    When I run the install command
    Then a file named "Berksfile.lock" should exist in the current directory
    And the file "Berksfile.lock" should contain in the current directory:
      """
      cookbook 'ntp', :locked_version => '1.1.8'
      cookbook 'mysql', :git => 'https://github.com/opscode-cookbooks/mysql.git', :ref => '190c0c2267785b7b9b303369b8a64ed04364d5f9'
      cookbook 'openssl', :locked_version => '1.0.0'
      cookbook 'chef_handler', :locked_version => '1.0.6'
      cookbook 'windows', :locked_version => '1.3.0'
      """
