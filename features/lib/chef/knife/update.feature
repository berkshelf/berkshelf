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
    When I run `knife cookbook dependencies update`
    Then the file "Cookbookfile.lock" should contain exactly:
    """
    cookbook 'mysql', :locked_version => '1.2.4'
    cookbook 'openssl', :locked_version => '1.0.0'
    """    

  Scenario: knife cookbook deps update
    Given I write to "Cookbookfile" with:
    """
    cookbook "mysql"
    """
    Given I write to "Cookbookfile.lock" with:
    """
    cookbook 'mysql', :locked_version => '0.0.1'
    cookbook 'openssl', :locked_version => '0.0.1'
    """
    When I run `knife cookbook deps update`
    Then the file "Cookbookfile.lock" should contain exactly:
    """
    cookbook 'mysql', :locked_version => '1.2.4'
    cookbook 'openssl', :locked_version => '1.0.0'
    """    
