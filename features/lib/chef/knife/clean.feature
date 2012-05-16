Feature: Clean
  As a user
  I want to be able to clean all the files downloaded/created by kcd
  So that I can be sure previous runs are not messing up my current action 
    and so I can get rid of installations I don't want any more

  Scenario: knife cookbook dependencies clean
    Given I write to "Cookbookfile" with:
    """
    cookbook "mysql"
    """
    When I run `knife cookbook dependencies install`
    And I run `knife cookbook dependencies clean`
    Then the following directories should not exist:
    | cookbooks |
    And the file "Cookbookfile.lock" should not exist
    And the temp directory should not exist
