# Contributing

## Developing

If you'd like to submit a patch:

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add [tests](#testing) for it. This is important so that it isn't broken in a
   future version unintentionally.
4. Commit. **Do not touch any unrelated code, such as the gemspec or version.**
   If you must change unrelated code, do it in a commit by itself, so that it
   can be ignored.
5. Send a pull request.

## Testing

### Install prerequisites

Install git on your test system.

Install the latest version of [Bundler](https://bundler.io/)

    $ gem install bundler

Clone the project

    $ git clone https://github.com/chef/berkshelf.git

and run:

    $ cd berkshelf
    $ bundle install

Bundler will install all gems and their dependencies required for testing and developing.

### Running unit (RSpec) and acceptance (Cucumber) tests

We use Chef Zero - an in-memory Chef Server for running tests. It is automatically managed by the Specs and Cukes. Run:

    $ bundle exec guard start

or
   
    $ bundle exec thor spec:ci

See [here](https://github.com/tdegrunt/vagrant-chef-server-bootstrap) for a
quick way to get a testing chef server up.

### Debugging Issues
By default, Berkshelf will only give you the top-level output from a failed command. If you're working deep inside the core, an error like:

    Berkshelf Error: wrong number of arguments (2 for 1)

isn't exactly helpful...

Specify the `BERKSHELF_DEBUG` flag when running your command to see a full stack trace and other helpful debugging information.

## Releasing

Once you are ready to release Berkshelf, perform the following:

1. Update `CHANGELOG.md` with a new header indicating the version to be released
1. Examine the diff ([example](https://github.com/chef/berkshelf/compare/v8.0.2...main)) between main and the previous version.  Add all merged Pull Requests to the `CHANGELOG.md`
1. Update `version.rb` to the desired release version
1. Run `bundle update berkshelf`
1. Create a PR and review the `version.rb` changes and `CHANGELOG.md` changes
1. Once the PR is merged to main, run `rake release` on the main branch
