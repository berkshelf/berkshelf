Feature: --format json
  As a user
  I want to be able to get all output in JSON format
  So I can easily parse the output in scripts

  Background:
    Given the Berkshelf API server's cache is empty
    And the Chef Server is empty
    And the cookbook store is empty

  Scenario: JSON output installing a cookbook from the default location
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf', '1.0.0'
      """
    And the Chef Server has cookbooks:
      | berkshelf | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    When I successfully run `berks install --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "version": "1.0.0",
            "name": "berkshelf"
          }
        ],
        "errors": [

        ],
        "messages": [
          "building universe..."
        ]
      }
      """

  Scenario: JSON output installing a cookbook we already have
    Given the cookbook store has the cookbooks:
      | berkshelf-cookbook-fixture   | 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'berkshelf-cookbook-fixture', '1.0.0'
      """
    When I successfully run `berks install --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "berkshelf-cookbook-fixture",
            "version": "1.0.0"
          }
        ],
        "errors": [

        ],
        "messages": [
          "building universe..."
        ]
      }
      """

  Scenario: JSON output when running the show command
    Given the cookbook store has the cookbooks:
      | fake | 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'fake', '1.0.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "fake": {
            "locked_version": "1.0.0"
          }
        }
      }
      """
    When I successfully run `berks show fake --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "fake",
            "version": "1.0.0",
            "description": "A fabulous new cookbook",
            "author": "YOUR_COMPANY_NAME",
            "email": "YOUR_EMAIL",
            "license": "none"
          }
        ],
        "errors": [

        ],
        "messages": [
        ]
      }
      """

  Scenario: JSON output when running the upload command
    Given I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'example_cookbook', path: '../../fixtures/cookbooks/example_cookbook-0.5.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "dependencies": {
          "example_cookbook": {
            "path": "../../fixtures/cookbooks/example_cookbook-0.5.0"
          }
        }
      }
      """
    When I successfully run `berks upload --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "example_cookbook",
            "version": "0.5.0",
            "uploaded_to": "http://localhost:26310/"
          }
        ],
        "errors": [

        ],
        "messages": [
        ]
      }
      """

  Scenario: JSON output when running the outdated command
    Given the cookbook store has the cookbooks:
      | seth | 0.1.0 |
    Given the Berkshelf API has the cookbooks:
      | seth | 0.1.0 |
      | seth | 0.2.9 |
      | seth | 1.0.0 |
    And I write to "Berksfile" with:
      """
      source "http://localhost:26210"

      cookbook 'seth', '~> 0.1'
      """
    And I successfully run `berks outdated --format json`
    Then the output should contain:
      """
      {
        "cookbooks": [
          {
            "version": "0.2.9",
            "sources": {
              "http://localhost:26210": {
                "name": "seth",
                "version": "0.2.9"
              }
            },
            "name": "seth"
          }
        ],
        "errors": [

        ],
        "messages": [
          "The following cookbooks have newer versions:"
        ]
      }
      """
