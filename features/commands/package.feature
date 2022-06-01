@api_server
Feature: berks package
  Background:
    * the cookbook store has the cookbooks:
      | fake | 1.0.0 |

  Scenario: When no options are passed
    Given I have a Berksfile pointing at the local Berkshelf API with:
      """
      cookbook 'fake', '~> 1.0.0'
      """
    When I successfully run `berks package my-cookbooks.tar.gz`
    Then a file named "my-cookbooks.tar.gz" should exist
    And the output should contain:
      """
      Cookbook(s) packaged to
      """
    And the archive "my-cookbooks.tar.gz" should contain:
      """
      cookbooks
      cookbooks/fake
      cookbooks/fake/attributes
      cookbooks/fake/attributes/default.rb
      cookbooks/fake/files
      cookbooks/fake/files/default
      cookbooks/fake/files/default/file.h
      cookbooks/fake/metadata.json
      cookbooks/fake/metadata.rb
      cookbooks/fake/recipes
      cookbooks/fake/recipes/default.rb
      cookbooks/fake/templates
      cookbooks/fake/templates/default
      cookbooks/fake/templates/default/template.erb
      """
