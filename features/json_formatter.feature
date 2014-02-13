Feature: --format json
  Background:
    * the Berkshelf API server's cache is empty
    * the Chef Server is empty
    * the cookbook store is empty

  Scenario: JSON output installing a cookbook from the default location
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
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
            "api_source": "http://0.0.0.0:26210",
            "location_path": "http://localhost:26310/",
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
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
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
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '1.0.0'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        fake (= 1.0.0)

      GRAPH
        fake (1.0.0)
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
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'example_cookbook', path: '../../fixtures/cookbooks/example_cookbook-0.5.0'
      """
    When I successfully run `berks upload --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "name": "example_cookbook",
            "version": "0.5.0",
            "location": "../../fixtures/cookbooks/example_cookbook-0.5.0",
            "uploaded_to": "http://localhost:26310/"
          }
        ],
        "errors": [

        ],
        "messages": [
          "building universe..."
        ]
      }
      """

  Scenario: JSON output when running the outdated command
    Given the cookbook store has the cookbooks:
      | seth | 0.1.0 |
    And the Chef Server has cookbooks:
      | seth | 0.1.0 |
      | seth | 0.2.9 |
      | seth | 1.0.0 |
    And the Berkshelf API server's cache is up to date
    And I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'seth', '~> 0.1'
      """
    And the I write to "Berksfile.lock" with:
      """
      DEPENDENCIES
        seth (~> 0.1)

      GRAPH
        seth (0.1.0)
      """
    And I successfully run `berks outdated --format json`
    Then the output should contain JSON:
      """
      {
        "cookbooks": [
          {
            "version": "0.2.9",
            "sources": {
              "http://0.0.0.0:26210": {
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
