# Berkshelf
[![Gem Version](https://img.shields.io/gem/v/berkshelf.svg)][gem]
[![CI Matrix Testing](https://github.com/chef/berkshelf/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/chef/berkshelf/actions/workflows/ci.yml?query=branch%3Amain)

[gem]: https://rubygems.org/gems/berkshelf

Manage Chef Infra cookbooks and cookbook dependencies

## Warning

Berkshelf is effectively deprecated. There is no ongoing maintenance and triage of issues. No active work is being done on bugfixes. The only
work being done is to maintain it so that it continues to ship and run in its existing state.

Existing users should strongly consider migrating to [Policyfiles](https://docs.chef.io/policyfile/) and new users should avoid using Berkshelf.

## Installation

Berkshelf is now included as part of the [Chef Workstation](https://downloads.chef.io/tools/workstation). This is fastest, easiest, and the recommended installation method for getting up and running with Berkshelf.

> note: You may need to uninstall the Berkshelf gem especially if you are using a Ruby version manager you may need to uninstall all Berkshelf gems from each Ruby installation.

### From Rubygems

If you are a developer or you prefer to install from Rubygems, we've got you covered.

Add Berkshelf to your repository's `Gemfile`:

```ruby
gem 'berkshelf'
```

Or run it as a standalone:

```shell
$ gem install berkshelf
```

## Usage

See [docs.chef.io](https://docs.chef.io/workstation/berkshelf/) for up-to-date usage instructions.

## CLI Usage

Berkshelf is intended to be used as a CLI tool.  It is not intended to be used as a library.  Other ruby code should shell out to the command line tool to use it.

## Supported Platforms

Berkshelf is tested and supported on Ruby 2.7 and later.

## Configuration

Berkshelf will search in specific locations for a configuration file. In order:

    $PWD/.berkshelf/config.json
    ~/.berkshelf/config.json

You are encouraged to keep project-specific configuration in the `$PWD/.berkshelf` directory. A default configuration file is generated for you, but you can update the values to suit your needs.

## Shell Completion

- [Bash](https://github.com/berkshelf/berkshelf-bash-plugin)
- [ZSH](https://github.com/berkshelf/berkshelf-zsh-plugin)

## Plugins

Please see [Plugins page](https://github.com/chef/berkshelf/blob/main/PLUGINS.md) for more information.

## Getting Help

* If you have an issue: report it on the [issue tracker](https://github.com/chef/berkshelf/issues)
* If you have a question: visit the #chef or #berkshelf channel on irc.freenode.net

## Authors

Thank you to all of our [Contributors](https://github.com/chef/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/chef/berkshelf/blob/main/CONTRIBUTING.md) first.

