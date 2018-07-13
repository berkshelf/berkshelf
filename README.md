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

```shell
$ gem install berkshelf
```

## Usage

See [docs.chef.io](https://docs.chef.io/berkshelf.html) for up-to-date usage instructions.

## CLI Usage

Berkshelf is intended to be used as a CLI tool.  It is not intended to be used as a library.  Other ruby code should shell out to the command line tool to use it.

## Supported Platforms

Berkshelf is tested and supported on Ruby 2.4 and 2.5.

## Configuration

Berskhelf uses Chef's standard config.rb/knife.rb file.

The old config.json berkshelf file has been deprecated.

A partial list of common berkshelf settings and their Chef Config settings for conversion:

| Berkshelf Config            | Chef Config                       |
|:--------------------------- |:--------------------------------- |
| timeout                     | rest_timeout                      |
| chef.chef_server_url        | chef_server_url                   |
| chef.validation_client_name | validation_client_name            |
| chef.validation_key_path    | validation_key                    |
| chef.client_key             | client_key                        |
| chef.node_name              | node_name                         |
| chef.trusted_certs_dir      | trusted_certs_dir                 |
| chef.artifactory_api_key    | artifactory_api_key               |
| ssl.verify                  | verify_api_cert / ssl_verify_mode |
| ssl.ca_path                 | ssl_ca_path                       |
| ssl.client_cert             | ssl_client_cert                   |
| ssl.client_key              | ssl_client_key                    |

## Shell Completion

- [Bash](https://github.com/berkshelf/berkshelf-bash-plugin)
- [ZSH](https://github.com/berkshelf/berkshelf-zsh-plugin)

## Getting Help

- Documentation: https://docs.chef.io/berkshelf.html
- Tickets/Issues: https://github.com/berkshelf/berkshelf/issues
- Slack: [Chef Community Slack](https://community-slack.chef.io/)
- Mailing list: https://discourse.chef.io

## Authors

Thank you to all of our [Contributors](https://github.com/berkshelf/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/berkshelf/berkshelf/blob/master/CONTRIBUTING.md) first.

