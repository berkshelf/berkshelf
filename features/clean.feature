Feature: Clean
  As a user
  I want to be able to clean all the files downloaded/created by kcd
  So that I can be sure previous runs are not messing up my current action 
    and so I can get rid of installations I don't want any more

  Scenario: knife cookbook dependencies clean
    Given I write to "Cookbookfile.lock" with:
      """
      cookbook "mysql", :locked_version => "1.2.0"
      """
    When I run the clean command
    And the file "Cookbookfile.lock" should not exist
