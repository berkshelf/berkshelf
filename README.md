# Berkshelf
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/RiotGames/berkshelf)

Manage a Cookbook or an Application's Cookbook dependencies

## Installation

    $ gem install berkshelf

## Usage

See [berkshelf.com](http://berkshelf.com) for up-to-date usage instructions.

# Contributing

## Running tests

### Install prerequisites

Install the latest version of [Bundler](http://gembundler.com)

    $ gem install bundler

Clone the project

    $ git clone git://github.com/RiotGames/berkshelf.git

and run:

    $ cd berkshelf
    $ bundle install

Bundler will install all gems and their dependencies required for testing and developing. 

### Running unit (RSpec) and acceptance (Cucumber) tests

    $ CHEF_CONFIG=~/.chef/knife.test-config.rb bundle exec guard start

Note that `CHEF_CONFIG` needs to be set to a meaningful value, otherwise
`~/.chef/knife.rb` will be used. **As we upload and purge cookbooks from the chef
servers during our test runs, this may not be what you desire!**

See [here](https://github.com/tdegrunt/vagrant-chef-server-bootstrap) for a
quick way to get a testing chef server up.

# Authors and Contributors

* Josiah Kiehl (<josiah@skirmisher.net>)
* Jamie Winsor (<jamie@vialstudios.com>)
* Erik Hollensbe (<erik@hollensbe.org>)
* Michael Ivey (<ivey@gweezlebur.com>)
