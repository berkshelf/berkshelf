Feature: Cookbookfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Cookbookfile 
  So when I share my repository, all other developers get the same versions that I did when I installed.

@wip
@slow_process
  Scenario: Writing the Cookbookfile.lock
    Given I write to "Cookbookfile" with:
    """
    cookbook 'ntp'
    cookbook 'mysql', git: 'https://github.com/opscode-cookbooks/mysql.git', :ref => '190c0c2267785b7b9b303369b8a64ed04364d5f9'
    cookbook 'example_cookbook', path: File.join(KCD.root, 'spec', 'fixtures', 'cookbooks')
    """
    When I run `knife cookbook dependencies install`
    When I sleep
    Then a file named "Cookbookfile.lock" should exist in the current directory
    And the file "Cookbookfile.lock" should contain in the current directory:
    """
    cookbook 'mysql', :git => 'https://github.com/opscode-cookbooks/mysql.git', :ref => '190c0c2267785b7b9b303369b8a64ed04364d5f9'
    cookbook 'example_cookbook', :path => .*
    cookbook 'ntp', :locked_version => '1.1.8'
    cookbook 'openssl', :locked_version => '1.0.0'
    cookbook 'windows', :locked_version => '1.2.12'
    cookbook 'chef_handler', :locked_version => '1.0.6'
    """
