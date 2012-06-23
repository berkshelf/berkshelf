# Berkshelf

Manages a Cookbook's, or an Application's, Cookbook dependencies

## Getting Started

### Install

    $ gem install berkshelf

### Use

#### Berksfile

Dependencies are managed via a `Berksfile` in the directory where you want the cookbooks to be installed.  The Berksfile, like Bundler's Gemfile, contains which cookbooks are needed and, optionally, where to find them:

    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'my_app', path: '/path/to/cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'

#### CLI

The CLI consists of 2 commands: install, update

    $ knife berks (install|update) [(--without|-W) group_to_exclude]

[install]  Installs the from the Berksfile.lock, or Berksfile if the the lockfile does not exist.

[update] Skips the lockfile and installs fresh

[init] Prepares a local path to have it's Cookbook dependencies managed by Berkshelf. If the target path is a Cookbook itself, additional Berkshelf support files will be generated to get you started.

## The Berksfile

Cookbooks are defined as dependencies by declaring them in the `Berksfile`

    cookbook 'nginx'

Cookbooks without additional options are assumed to come from the Opscode Community site at the latest available version: http://community.opscode.com/cookbooks

Options available include:

version constraint

    cookbook "nginx", "= 0.101.2"    # precisely 0.101.2
    cookbook "mysql", "< 1.2.4"      # less than and not including 1.2.4
    cookbook "openssl", "~> 1.0.0"   # greater than 1.0.0, and up to but not including 1.1.0

git

    # ref can be a branch name, tag, or commit hash. If ref is not provided, HEAD is used.
    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", ref: "<any git ref>" 

path

    # knife berks will look in /path/to/location/of/my_application for the cookbook
    cookbook "my_application", path: "/path/to/location/of"

### Groups

Groups can be defined via blocks or inline as an option:

    group :solo do
      cookbook 'base'
    end
    
    cookbook 'base', :group => 'solo'

When using install or update, groups can be excluded with the --without GROUP_NAME or -W GROUP_NAME flags.

# Contributing

## Running tests

### Install prerequisites

Install the latest version of {Bundler}[http://gembundler.com]

    $ gem install bundler

Clone the project

    $ git clone git://github.com/RiotGames/berkshelf.git

and run:

    $ cd berkshelf
    $ bundle install

Bundler will install all gems and their dependencies required for testing and developing. 

### Running unit (RSpec) and acceptance (Cucumber) tests

    $ bundle exec guard start

# Authors and Contributors

* Josiah Kiehl (<josiah@skirmisher.net>)
* Jamie Winsor (<jamie@vialstudios.com>)
* Erik Hollensbe (<erik@hollensbe.org>)
* Michael Ivey (<ivey@gweezlebur.com>)
