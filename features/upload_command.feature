Feature: upload command
  As a KCD CLI user
  I need a way to upload cookbooks to a Chef server that I have installed into my Bookshelf
  So they are available to Chef clients

  @wip @slow_process
  Scenario: running the upload command when the Sources in the Cookbookfile are already installed
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And the Chef server does not have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And I run the install command
    When I run the upload command
    Then the output should not contain "Using mysql (1.2.4)"
    And the output should not contain "Using openssl (1.0.0)"
    And the output should contain "Uploading mysql (1.2.4) to:"
    And the output should contain "Uploading openssl (1.0.0) to:"
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the exit status should be 0

  @slow_process
  Scenario: running the upload command when the Sources in the Cookbookfile have not been installed
    Given I write to "Cookbookfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    And the Chef server does not have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    When I run the upload command
    Then the output should contain "Installing mysql (1.2.4) from site:"
    And the output should contain "Installing openssl (1.0.0) from site:"
    And the output should contain "Uploading mysql (1.2.4) to:"
    And the output should contain "Uploading openssl (1.0.0) to:"
    And the Chef server should have the cookbooks:
      | mysql   | 1.2.4 |
      | openssl | 1.0.0 |
    And the exit status should be 0
