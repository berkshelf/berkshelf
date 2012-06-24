## Install

    $ gem install berkshelf

## Getting Started

### Berksfile

Dependencies are managed via a `Berksfile` in the directory where you want the cookbooks to be installed.  The Berksfile, like Bundler's Gemfile, contains which cookbooks are needed and, optionally, where to find them:

    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'my_app', path: '/path/to/cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'

Once you have a Berksfile run the install command and the Cookbooks and their dependencies, recurisively, will be installed to a central location on your local disk called a `Berkshelf`. The Berkshelf is by default located at `~/.berkshelf`.

    $ knife berks install

## CLI Commands

### knife berks install

Install the Cookbooks defined by sources in your Berksfile and their dependencies, recursively, to your Berkshelf.

    $ knife berks install

A Berksfile.lock will be generated if one does not already exist that will contain the dependency solution.

If a Berksfile.lock is present when the install command is run, the locked sources in the Lockfile will take precedence over any sources defined in the Berksfile.

### knife berks update

This will still perform an install on your Berksfile, but it will skip a Lockfile if it is present and install fresh

    $ knife berks update

### knife berks init

Prepares a local path to have it's Cookbook dependencies managed by Berkshelf. If the target path is a Cookbook itself, additional Berkshelf support files will be generated to get you started.

    $ knife berks init nginx-cookbook

## Berkshelf with Vagrant

Because Berkshelf stores your Cookbooks in a central location and can store multiple versions of the same Cookbook, we need a way to present these Cookbooks in a structure that is familiar to other tools that expect your Cookbooks to be located all in the same directory and have their folder names the same as the Cookbook name.

### Shims

Enter shims

    a shim (from shim) or shiv is a small library that transparently intercepts an API and changes the parameters
    passed, handles the operation itself, or redirects the operation elsewhere.

Berkshelf handles shims by hard linking Cookbooks from your Berkshelf to a directory named `cookbooks` in your current working directory. You can install shims by adding the `--shims` flag to the install command.

    $ knife berks install --shims

If we had a Berksfile that had a source for

    cookbook "nginx", "= 0.100.5"

This would install your Cookbook to `~/.berkshelf/nginx-0.100.5` and also create a shim at `cookbooks/nginx`.

In your Vagrant file you should add this shims directory to the `cookbooks_path`

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = [ "cookbooks" ]
    end

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
