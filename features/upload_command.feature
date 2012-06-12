Feature: initialize command
  As a KCD CLI user
  I need a way to upload cookbooks to a Chef server that I have installed into my Bookshelf
  So they are available to Chef cleints

  @wip
  Scenario: running the upload command when the Cookbookfile contains only cookbooks that have been installed
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And I run the install command
    When I run the upload command
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the output should contain "Upload complete"
    And the exit status should be 0

  @wip
  Scenario: running the upload command when the Cookbookfile contains cookbooks that have not been installed
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I run the upload command
    Then the cookbook store should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the output should contain "Upload complete"
    And the exit status should be 0
