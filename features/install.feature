Feature: install cookbooks from a Cookbookfile
  As a user with a Cookbookfile
  I want to be able to run knife cookbook dependencies install to install my cookbooks
  So that I don't have to download my cookbooks and their dependencies manually

  Scenario: install cookbooks
    Given I write to "Cookbookfile" with:
    """
    cookbook "mysql"
    """
    When I run `knife cookbook dependencies install`
    Then the following directories should exist:
    | cookbooks/mysql   |
    | cookbooks/openssl |

  Scenario: install cookbooks with the alias
    Given I write to "Cookbookfile" with:
    """
    cookbook "mysql"
    """
    When I run `knife cookbook deps install`
    Then the following directories should exist:
    | cookbooks/mysql   |
    | cookbooks/openssl |
