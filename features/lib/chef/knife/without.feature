Feature: --without block
  As a user
  I want to be able to exclude blocks in my Cookbookfile
  So I can have cookbooks organized for use in different situations in a single Cookbookfile

  @slow_process
  Scenario: Exclude a block
    Given I write to "Cookbookfile" with:
    """
    group :notme do
      cookbook "nginx"
    end
    
    cookbook "mysql"

    group :takeme do
      cookbook "ntp"
    end
    """
    When I run `knife cookbook dependencies install --without notme`
    Then the following directories should exist:
    | cookbooks/mysql   |
    | cookbooks/openssl |
    | cookbooks/ntp     |
    And the following directories should not exist:
    | cookbooks/nginx |

