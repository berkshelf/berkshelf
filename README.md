# Berkshelf
[![Gem Version](https://img.shields.io/gem/v/berkshelf.svg)][gem]
[![Build Status](https://img.shields.io/travis/berkshelf/berkshelf.svg)][travis]

[gem]: https://rubygems.org/gems/berkshelf
[travis]: https://travis-ci.org/berkshelf/berkshelf

Manage a Cookbook or an Application's Cookbook dependencies

## Installation

Berkshelf is now included as part of the [Chef-DK](https://downloads.chef.io/chef-dk/). This is fastest, easiest, and the recommended installation method for getting up and running with Berkshelf.

> note: You may need to uninstall the Berkshelf gem especially if you are using a Ruby version manager you may need to uninstall all Berkshelf gems from each Ruby installation.

### From Rubygems

If you are a developer or you prefer to install from Rubygems, we've got you covered.

Add Berkshelf to your repository's `Gemfile`:

```ruby
gem 'berkshelf'
```

Or run it as a standalone:

    $ gem install berkshelf

## Usage

See [berkshelf.com](http://berkshelf.com) for up-to-date usage instructions.

## Supported Platforms

Berkshelf is tested on Ruby 1.9.3, 2.0, and 2.1.

Ruby 1.9 mode is required on all interpreters.

Ruby 1.9.1 and 1.9.2 are not officially supported. If you encounter problems, please upgrade to Ruby 2.0 or 1.9.3.

## Configuration

Berkshelf will search in specific locations for a configuration file. In order:

    $PWD/.berkshelf/config.json
    ~/.berkshelf/config.json

You are encouraged to keep project-specific configuration in the `$PWD/.berkshelf` directory. A default configuration file is generated for you, but you can update the values to suit your needs.

## Shell Completion

- [Bash](https://github.com/berkshelf/berkshelf-bash-plugin)
- [ZSH](https://github.com/berkshelf/berkshelf-zsh-plugin)

## Plugins

Please see [Plugins page](https://github.com/berkshelf/berkshelf/blob/master/PLUGINS.md) for more information.

## Getting Help

* If you have an issue: report it on the [issue tracker](https://github.com/berkshelf/berkshelf/issues)
* If you have a question: visit the #chef or #berkshelf channel on irc.freenode.net

## Authors

[The Berkshelf Core Team](https://github.com/berkshelf/berkshelf/wiki/Core-Team)

Thank you to all of our [Contributors](https://github.com/berkshelf/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/berkshelf/berkshelf/blob/master/CONTRIBUTING.md) first.
