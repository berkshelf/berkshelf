Feature: berks init
  Scenario: initializing a path containing a cookbook
    * a cookbook named "myface"
    * I successfully run `berks init myface`
    * the cookbook "myface" should have the following files:
      | Berksfile  |
      | chefignore |
    * the file "Berksfile" in the cookbook "myface" should contain:
      """
      metadata
      """
    * the output should contain "Successfully initialized"

  Scenario: initializing a path that does not contain a cookbook
    * a directory named "not_a_cookbook"
    * I run `berks init not_a_cookbook`
    * the exit status should be "NotACookbook"

  Scenario: initializing with no value given for target
    * I write to "metadata.rb" with:
      """
      name 'myface'
      """
    * I successfully run `berks init`
    * the output should contain "Successfully initialized"
    * a file named "Berksfile" should exist
    * a file named "chefignore" should exist

  Scenario: With the default options
    * I successfully run `berks cookbook myface`
    * I should have a new cookbook skeleton "myface"

  Scenario: --bundler
    * I successfully run `berks cookbook --bundler myface`
    * a file named "myface/Gemfile" should exist
    * the output should contain "Run `bundle install` to install any new gems."

  Scenario: --no-bundler
    * I successfully run `berks cookbook --no-bundler myface`
    * a file named "myface/Gemfile" should not exist

  Scenario: --chefignore
    * I successfully run `berks cookbook --chefignore myface`
    * a file named "myface/chefignore" should exist

  Scenario: --no-chefignore
    * I successfully run `berks cookbook --no-chefignore myface`
    * a file named "myface/chefignore" should not exist

  Scenario: --chefspec
    * I successfully run `berks cookbook --chefspec myface`
    * the file "myface/Gemfile" should contain "gem 'chefspec'"
    * a file named "myface/spec/spec_helper.rb" should exist
    * a file named "myface/spec/recipes/default_spec.rb" should exist

  Scenario: --no-chefspec
    * I successfully run `berks cookbook --no-chefspec myface`
    * the file "myface/Gemfile" should not contain "gem 'chefspec'"
    * a file named "myface/spec/spec_helper.rb" should not exist
    * a file named "myface/spec/recipes/default_spec.rb" should not exist

  Scenario: --foodcritic
    * I successfully run `berks cookbook --foodcritic myface`
    * the file "myface/Gemfile" should contain "gem 'foodcritic'"

  Scenario: --no-foodcritic
    * I successfully run `berks cookbook --no-foodcritic myface`
    * the file "myface/Gemfile" should not contain "gem 'foodcritic'"

  Scenario: --git
    * I successfully run `berks cookbook --git myface`
    * a directory named "myface/.git" should exist
    * a file named "myface/.gitignore" should exist

  Scenario: --no-git
    * I successfully run `berks cookbook --no-git myface`
    * a directory named "myface/.git" should not exist
    * a file named "myface/.gitignore" should not exist

  Scenario: --minitest
    * I successfully run `berks cookbook --minitest myface`
    * a file named "myface/files/default/tests/minitest/support/helpers.rb" should exist
    * a file named "myface/files/default/tests/minitest/default_test.rb" should exist

  Scenario: --no-minitest
    * I successfully run `berks cookbook --no-minitest myface`
    * a directory named "myface/files/default/tests" should not exist

  Scenario: --scmversion
    * I successfully run `berks cookbook --scmversion myface`
    * a file named "myface/VERSION" should exist

  Scenario: --no-scmversion
    * I successfully run `berks cookbook --no-scmversion myface`
    * a file named "myface/VERSION" should not exist

  # Need to spawn a subprocess or the generator fails
  @spawn
  Scenario: --test-kitchen
    * I successfully run `berks cookbook --test-kitchen myface`
    * a file named "myface/.kitchen.yml" should exist

  Scenario: --no-test-kitchen
    * I successfully run `berks cookbook --no-test-kitchen myface`
    * a file named "myface/.kitchen.yml" should not exist

  Scenario: --vagrant
    * I successfully run `berks cookbook --vagrant myface`
    * a file named "myface/Vagrantfile" should exist

  Scenario: --no-vagrant
    * I successfully run `berks cookbook --no-vagrant myface`
    * a file named "myface/Vagrantfile" should not exist

  Scenario Outline: When a required supporting gem is not installed
    * the gem "<gem>" is not installed
    * I successfully run `berks cookbook --<option> --no-bundler myface`
    * the output should contain "To make use of <gem>, run `gem install <gem>`"
  Examples:
    | option       | gem             |
    | chefspec     | chefspec        |
    | foodcritic   | foodcritic      |
    | scmversion   | thor-scmversion |
    | test-kitchen | test-kitchen    |
