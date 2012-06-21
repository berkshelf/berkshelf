Feature: --without block
  As a user
  I want to be able to exclude blocks in my Cookbookfile
  So I can have cookbooks organized for use in different situations in a single Cookbookfile

  @slow_process
  Scenario: Exclude a block
    Given I write to "Cookbookfile" with:
      """
      group :notme do
        cookbook "nginx", "= 0.101.2"
      end
      
      cookbook "mysql", "= 1.2.4"

      group :takeme do
        cookbook "ntp", "= 1.1.8"
      end
      """
    When I run `knife berkshelf install --without notme`
    Then the cookbook store should have the cookbooks:
      | mysql | 1.2.4 |
      | ntp   | 1.1.8 |
    And the cookbook store should not have the cookbooks:
      | nginx | 0.101.2 |
