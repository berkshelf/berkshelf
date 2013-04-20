Feature: lock cookbook versions on the server
  As a berks user
  I want to push my berks resolved cookbook versions to my environment
  So that I can avoid manual configuration of my environments

  @chef_server
  Scenario: locking cookbook versions
    Given I have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I successfully run `berks lock berkshelf_lock_test`
    Then the version locks in "berkshelf_lock_test" should be:
    | cookbook        | version_lock |
    | mysql           |        1.2.4 |

  @chef_server
  Scenario: locking cookbook versions with the include_dependencies flag
    Given I have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I successfully run `berks lock berkshelf_lock_test --include_dependencies`
    Then the version locks in "berkshelf_lock_test" should be:
    | cookbook        | version_lock |
    | mysql           |        1.2.4 |
    | openssl         |        1.0.2 |

  @chef_server
  Scenario: locking cookbook versions with the include_dependencies alias flag
    Given I have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I successfully run `berks lock berkshelf_lock_test -a`
    Then the version locks in "berkshelf_lock_test" should be:
    | cookbook        | version_lock |
    | mysql           |        1.2.4 |
    | openssl         |        1.0.2 |

    @chef_server
  Scenario: locking cookbook versions to an environment that does not exist
    Given I do not have an environment named "berkshelf_lock_test"
    And I write to "Berksfile" with:
      """
      cookbook "mysql", "1.2.4"
      """
    When I run `berks lock berkshelf_lock_test`
    Then the output should contain:
      """
      The environment "berkshelf_lock_test" does not exist.
      """
