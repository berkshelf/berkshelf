## Getting Started

Berkshelf is now included as part of the [Chef-DK](http://getchef.com/downloads/chef-dk). This is fastest, easiest, and the recommended installation method for getting up and running with Berkshelf.

Add the Chef-DK binaries directory to your path once you've installed the Chef-DK.

    $ export PATH=/opt/chefdk/embedded/bin:$PATH
    $ which berks
    /opt/chefdk/embedded/bin/berks

Generate a Berksfile in a pre-exisitng cookbook

    $ cd my-cookbook
    $ berks init .

Or create a new cookbook

    $ berks cookbook myapp

And specify your dependencies in a Berksfile in your cookbook's root

    source "https://api.berkshelf.com"

    metadata

    cookbook "mysql"
    cookbook "nginx", "~> 2.6"

Install the cookbooks you specified in the Berksfile and their dependencies

    $ berks install

## Getting Help

If at anytime you are stuck or if you're just curious about what Berkshelf can do, just type the help command

    $ berks help

You can get more detailed information about a command, or a sub command, but asking it for help

    $ berks install help

    Usage:
      berks install

    Options:
      -e, [--except=one two three]  # Exclude cookbooks that are in these groups.
      -o, [--only=one two three]    # Only cookbooks that are in these groups.
      -b, [--berksfile=PATH]        # Path to a Berksfile to operate off of.
                                    # Default: Berksfile
      -c, [--config=PATH]           # Path to Berkshelf configuration to use.
      -F, [--format=FORMAT]         # Output format to use.
                                    # Default: human
      -q, [--quiet], [--no-quiet]   # Silence all informational output.
      -d, [--debug], [--no-debug]   # Output debug information

    Install the cookbooks specified in the Berksfile

## The Berkshelf

> After running `berks install` you may ask yourself, "Where did my cookbooks go?". They were added to The Berkshelf.

The Berkshelf is a location on your local disk which contains the cookbooks you have installed and their dependencies. By default, The Berkshelf is located at `~/.berkshelf` but this can be altered by setting the environment variable `BERKSHELF_PATH`.

Berkshelf stores every version of a cookbook that you have ever installed. This is the same pattern found with RubyGems where once you have resolved and installed a gem, you will have that gem and it's dependencies until you delete it.

This central location is not the typical pattern of cookbook storage that you may be used to with Chef. The traditional pattern is to place all of your cookbooks in a directory called `cookbooks` or `site-cookbooks` within your [Chef Repository](http://wiki.opscode.com/display/chef/Chef+Repository). We do have all of our cookbooks in one central place, it's just not the Chef Repository and they're stored within directories named using the convention `{name}-{version}`.

Given you have the cookbooks installed:

    * nginx - 2.6.4
    * mysql - 5.1.9

These cookbooks will be located at:

    ~/.berkshelf/cookbooks/nginx-2.6.4
    ~/.berkshelf/cookbooks/mysql-5.1.9

> It is now *REQUIRED* for the name attribute to be set in your cookbook's metadata. If you have a cookbook which does not specify this, it will need to be added.

### Packaging Cookbooks

A single archive containing all of your required cookbooks can be created with the package command

    $ cd ~/code/berkshelf-api/cookbook
    $ berks package
    Cookbook(s) packaged to /Users/reset/code/berkshelf-api/cookbook/cookbooks-1397512169.tar.gz

This archive an be given directly to Chef-Solo or extracted and uploaded to a Chef Server.

### Vendoring Cookbooks

If you don't want to create a package but you want to install the cookbooks to a location on disk that is not the berkshelf, you can use the vendor command

    $ berks vendor

This will output all of the cookbooks to `pwd/berks-cookbooks`

## Configuring Berkshelf

Berkshelf will run with a default configuration unless you explicitly generate one. By default, Berkshelf uses the values found in your Knife configuration (if you have one).

You can override this default behavior by create a configuration file and placing it at `~/.berkshelf/config.json`

### Configurable options

* `chef.chef_server_url` - URL to a Chef Server API endpoint. (default: whatever is in your Knife file if you have one)
* `chef.node_name` - your Chef API client name. (default: whatever is in your Knife file if you have one)
* `chef.client_key` - filepath to your Chef API client key. (default: whatever is in your Knife file if you have one)
* `chef.validation_client_name` - your Chef API's validation client name. (default: whatever is in your Knife file if you have one)
* `chef.validation_key_path` - filepath to your Chef API's validation key. (default: whatever is in your Knife file if you have one)
* `vagrant.vm.box` - name of the VirtualBox box to use when provisioning Vagrant virtual machines. (default: Berkshelf-CentOS-6.3-x86_64-minimal)
* `vagrant.vm.box_url` - URL to the VirtualBox box (default: https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box)
* `vagrant.vm.forward_port` - a Hash of ports to forward where the key is the port to forward to on the guest and value is the host port which forwards to the guest on your host.
* `vagrant.vm.provision` - use the `chef_solo` or `chef_client` provisioner? (default: chef_solo)
* `ssl.verify` - should we verify all SSL http connections? (default: true)
* `cookbook.copyright` - the copyright information should be included when you generate new cookbooks. (default: whatever is in your Knife file if you have one)
* `cookbook.email` - the email address to include when you generate new cookbooks. (default: whatever is in your Knife file if you have one)
* `cookbook.license` - the license to use when you generate new cookbooks. (default: whatever is in your Knife file if you have one)
* `github` - an array of hashes containing Github credentials to authenticate against downloading cached Github cookbooks.

> The configuration values are notated in 'dotted path' format. These translate to a nested JSON structure.

## Vagrant with Berkshelf

Berkshelf was designed for iterating on cookbooks and applications quickly. [Vagrant](http://vagrantup.com) provides us with a way to spin up a virtual environment and configure it using a built-in Chef provisioner. If you have never used Vagrant before - stop now - read the Vagrant documentation and give it a try. Your cookbook development life is about to become 100% better.

If you have used Vagrant before, READ ON!

### Install Vagrant

Visit the [Vagrant downloads page](http://downloads.vagrantup.com/) and download the latest installer for your operating system.

### Install the Vagrant Berkshelf plugin

    $ vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
    Installing the 'vagrant-berkshelf' plugin. This can take a few minutes...
    Installed the plugin 'vagrant-berkshelf (2.0.1)!'

### Using the Vagrant Berkshelf plugin

Once the Vagrant Berkshelf plugin is installed it can be enabled in your Vagrantfile

    Vagrant.configure("2") do |config|
      ...
      config.berkshelf.enabled = true
      ...
    end

> If your Vagrantfile was generated by Berkshelf it's probably already enabled

The plugin will look in your current working directory for your `Berksfile` by default. Just ensure that your Berksfile exists and when you run `vagrant up`, `vagrant provision`, or `vagrant destroy` the Berkshelf integration will automatically kick in!

    $ vagrant provision
    [Berkshelf] Updating Vagrant's berkshelf: '/Users/reset/.berkshelf/vagrant/berkshelf-20130320-28478-sy1k0n'
    [Berkshelf] Installing nginx (2.6.0)
    ...

You can use both the Vagrant provided Chef Solo and Chef Client provisioners with the Vagrant Berkshelf plugin.

#### Chef Solo provisioner

The Chef Solo provisioner's `cookbook_path` attribute is hijacked when using the Vagrant Berkshelf plugin. Cookbooks resolved from your Berksfile will automatically be made available to your Vagrant virtual machine. There is no need to explicitly set a value for `cookbook_path` attribute.

#### Chef Client provisioner

Cookbooks will automatically be uploaded to the Chef Server you have configured in the Vagrantfile's Chef Client provisioner block. Your Berkshelf configuration's `chef.node_name` and `chef.client_key` credentials will be used to authenticate the upload.

## The Berksfile

Dependencies are managed via the file `Berksfile`. The Berksfile is like Bundler's Gemfile. Entries in the Berskfile are known as sources. It contains a list of sources identifying what Cookbooks to retrieve and where to get them.

    source "https://api.berkshelf.com"

    metadata

    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'pvpnet', path: '/Users/reset/code/riot-cookbooks/pvpnet-cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'

All dependencies _and_ their dependencies (and their dependencies, etc) will be downloaded, recursively. Two keywords can be used for defining dependencies.

### Metadata keyword

The metadata keyword is like saying `gemspec` in Bundler's [Gemfile](http://gembundler.com/man/gemfile.5.html). It says, "There is a metadata.rb file within the same relative path of my Berksfile". This allows you to resolve a Cookbook's dependencies that you are currently working on just like you would resolve the dependencies of a Gem that you are currently working on with Bundler.

Given a Berksfile at `~/code/nginx-cookbook` containing:

    metadata

A `metadata.rb` file is assumed to be located at `~/code/nginx-cookbook/metadata.rb` describing your nginx cookbook.

### Cookbook keyword

The cookbook keyword is a way to describe a cookbook to install or a way to override the location of a dependency.

Cookbook sources are defined with the format:

    cookbook {name}, {version_constraint}, {options}

The first parameter is the `name` and is the only required parameter

    cookbook "nginx"

The second parameter is a `version constraint` and is optional. If no version constraint is specified the latest is assumed

    cookbook "nginx", ">= 0.101.2"

Constraints can be specified as

* Equal to (=)
* Greater than (>)
* Greater than or equal to (>=)
* Less than (<)
* Less than or equal to (<=)
* Pessimistic (~>)

The final parameter is an options hash

### Source Options

Options passed to a source can contain a location or a group(s).

#### Locations

By default the location of a cookbook is assumed to come from one of the api sources that you have configured. For example

    source "https://berks-api.vialstudios.com"
    source "https://api.berkshelf.com"

If a cookbook which satisfies all demands is found in `berks-api.vialstudios.com` then it will be retrieved and used in resolution. If it is not, then any subsequent defined sources will be used. If no sources can satisfy the demand a no solution error will be returned.

Explicit locations can be used to override the cookbooks found at these sources

##### Path Location

The Path location is useful for rapid iteration because it does not download, copy, or move the cookbook to The Berkshelf or change the contents of the target. Instead the cookbook found at the given filepath will be used alongside the cookbooks found in The Berkshelf.

    cookbook "artifact", path: "/Users/reset/code/artifact-cookbook"

The value given to the `path` key can only contain a single cookbook and _must_ contain a `metadata.rb` file.

##### Git Location

The Git location will clone the given Git repository to The Berkshelf if the Git repository contains a valid cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git"

Given the previous example, the cookbook found at the HEAD revision of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `branch` key can be specified whose value is a branch or tag that contains the desired cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", branch: "foodcritic"

Given the previous example, the cookbook found at branch `foodcritic` of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `tag` key is an alias for `branch` and can be used interchangeably.

   cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", tag: "3.0.2"

Given the previous example, the cookbook found at tag `3.0.2` of the  opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `ref` key can be specified for the exact SHA-1 commit ID to use and exact revision of the desired cookbook.

   cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", ref: "eef7e65806e7ff3bdbe148e27c447ef4a8bc3881"

Given the previous example, the cookbook found at commit id `eef7e65806e7ff3bdbe148e27c447ef4a8bc3881` of the  opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `rel` key can be specified if your repository contains many cookbooks in a single repository under a sub-directory or at root.

    cookbook "rightscale", git: "https://github.com/rightscale/rightscale_cookbooks.git", rel: "cookbooks/rightscale"

This will fetch the cookbook `rightscale` from the speficied Git location from under the `cookbooks` sub-directory.

##### GitHub Location

As of version 1.0.0, you may now use GitHub shorthand to specify a location.

    cookbook "artifact", github: "RiotGames/artifact-cookbook", tag: "0.9.8"

Given this example, the `artifact` cookbook from the `RiotGames` organization in the `artifact-cookbook` repository with a tag of `0.9.8` will be cloned to The Berkshelf.

The `git` protocol will be used if no protocol is explicity set. To access a private repository specify the `ssh` or `https` protocol.

    cookbook "keeping_secrets", github: "RiotGames/keeping_secrets-cookbook", protocol: :ssh

> You will receive a repository not found error if you are referencing a private repository and have not set the protocol to `https` or `ssh`.

### Groups

Adding sources to a group is useful if you want to ignore a cookbook or a set of cookbooks at install or upload time.

Groups can be defined via blocks:

    group :solo do
      cookbook 'riot_base'
    end

Groups can also be defined inline as an option:

    cookbook 'riot_base', group: 'solo'

To exclude the groups when installing or updating just add the `--without` flag.

    $ berks install --without solo
