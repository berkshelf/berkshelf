## Getting Started

Getting started with Berkshelf is a breeze.

    $ gem install berkshelf
    Successfully installed berkshelf-3.0.0
    1 gem installed

Specify your cookbook dependencies in a Berksfile in your project's root

    # Berksfile
    cookbook 'mysql'
    cookbook 'nginx', '~> 2.0.0'

Install the cookbooks you specified in the Berksfile and their dependencies

    $ berks install

Add the Berksfile to your project

    $ git add Berksfile
    $ git commit -m "add Berksfile to project"

> A Berksfile.lock will also be created. Add this to version control if you want to ensure that
> other developers (or your build server) will use the same versions of all cookbook dependencies.

### Managing an existing Cookbook

If you already have a cookbook and it's not managed by Berkshelf it's easy to get up and running. Just locate your cookbook and initialize it!

    $ berks init ~/code/mushroom-cookbook

Note how the Berksfile in this case tells Berkshelf to read the cookbook's metadata, rather than specifying the dependencies directly

    # Berksfile
    metadata

### Creating a new Cookbook

Want to start a new cookbook for a new application or supporting application?

    $ berks cookbook new_application

## Getting Help

If at anytime you are stuck or if you're just curious about what Berkshelf can do, just type the help command

    $ berks help

    Commands:
      berks apply ENVIRONMENT     # Apply the cookbook version locks from Berksfile.lock to a Chef environment
      berks configure             # Create a new Berkshelf configuration file
      berks contingent COOKBOOK   # List all cookbooks that depend on the given cookbook
      berks cookbook NAME         # Create a skeleton for a new cookbook
      berks help [COMMAND]        # Describe available commands or one specific command
      berks init [PATH]           # Initialize Berkshelf in the given directory
      berks install               # Install the cookbooks specified in the Berksfile
      berks list                  # List all cookbooks and their dependencies specified by your Berksfile
      berks outdated [COOKBOOKS]  # List dependencies that have new versions available that satisfy their constraints
      berks package [COOKBOOK]    # Package a cookbook and it's dependencies as a tarball
      berks shelf SUBCOMMAND      # Interact with the cookbook store
      berks show [COOKBOOK]       # Display name, author, copyright, and dependency information about a cookbook
      berks update [COOKBOOKS]    # Update the cookbooks (and dependencies) specified in the Berksfile
      berks upload [COOKBOOKS]    # Upload the cookbook specified in the Berksfile to the Chef Server
      berks vendor [PATH]         # Vendor the cookbooks specified by the Berksfile into a directory
      berks version               # Display version and copyright information

    Options:
      -c, [--config=PATH]    # Path to Berkshelf configuration to use.
      -F, [--format=FORMAT]  # Output format to use.
                             # Default: human
      -q, [--quiet]          # Silence all informational output.
      -d, [--debug]          # Output debug information

You can get more detailed information about a command, or a sub command, but asking it for help

    $ berks shelf help

    Commands:
      berks shelf help [COMMAND]  # Describe subcommands or one specific subcommand
      berks shelf list            # List all cookbooks and their versions
      berks shelf show            # Display information about a cookbook in the Berkshelf shelf
      berks shelf uninstall       # Remove a cookbook from the Berkshelf shelf

## The Berkshelf

> After running `berks install` you may ask yourself, "Where did my cookbooks go?". They were added to The Berkshelf.

The Berkshelf is a location on your local disk which contains the cookbooks you have installed and their dependencies. By default, The Berkshelf is located at `~/.berkshelf` but this can be altered by setting the environment variable `BERKSHELF_PATH`.

Berkshelf stores every version of a cookbook that you have ever installed. This is the same pattern found with RubyGems where once you have resolved and installed a gem, you will have that gem and it's dependencies until you delete it.

This central location is not the typical pattern of cookbook storage that you may be used to with Chef. The traditional pattern is to place all of your cookbooks in a directory called `cookbooks` or `site-cookbooks` within your [Chef Repository](http://wiki.opscode.com/display/chef/Chef+Repository). We do have all of our cookbooks in one central place, it's just not the Chef Repository and they're stored within directories named using the convention `{name}-{version}`.

Given you have the cookbooks installed:

    * nginx - 2.0.0
    * mysql - 3.0.12

These cookbooks will be located at:

    ~/.berkshelf/cookbooks/nginx-2.0.0
    ~/.berkshelf/cookbooks/mysql-3.0.12

By default Chef interprets the name of a cookbook by the directory name. Some Chef internals weigh the name of the directory more heavily than if a cookbook developer were to explicitly set the `name` attribute in their metadata. Because the directory structure contains the cookbook's version number, do not treat The Berkshelf as just another entry in your `Chef::Config#cookbooks_path`.

### Vendoring Cookbooks

You can easily install your Cookbooks and their dependencies to a location other than The Berkshelf. A good case for this is when you want to "vendor" your cookbooks to be packaged and distributed.

    $ berks install --path vendor/cookbooks

This will install your Cookbooks to the `vendor/cookbooks` directory relative to where you ran the command from. Inside the vendored cookbooks directory you will find a directory named after the cookbook it contains.

## Configuring Berkshelf

Berkshelf will run with a default configuration unless you explicitly generate one. The configuration will attempt to populate itself with values found in your Knife configuration (if you have one) and fill in the rest with other sensible defaults.

You can configure Berkshelf to your liking with the `configure` command

    $ berks configure

Answer each question prompt with a value or just press enter to accept the default value.

    Config written to: '/Users/teemo/.berkshelf/config.json'

You will only be prompted to fill in the most travelled configuration options. Looking in the generated configuration will give you some insight to some other configurable values.

    {
      "chef": {
        "chef_server_url": "https://api.opscode.com/organizations/riot",
        "validation_client_name": "riot-validator",
        "validation_key_path": "/Users/teemo/.chef/riot-validator.pem",
        "client_key": "/Users/teemo/.chef/teemo.pem",
        "node_name": "teemo"
      },
      "cookbook": {
        "copyright": "Riot Games",
        "email": "teemo@riotgames.com",
        "license": "reserved"
      },
      "allowed_licenses": [
      ],
      "raise_license_exception": false,
      "vagrant": {
        "vm": {
          "box": "opscode_ubuntu-12.04_provisionerless",
          "box_url": "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box",
          "forward_port": {
          },
          "network": {
            "bridged": false,
            "hostonly": "33.33.33.10"
          },
          "provision": "chef_solo"
        },
        "omnibus": {
          "enabled": true,
          "version": "latest"
        }
      },
      "ssl": {
        "verify": true
      }
    }    

### Configurable options

* `chef.chef_server_url` [String] Location of your chef server's API endpoint (e.g. http://api.opscode.com/organizations/riot) Default: knife configuration
* `chef.validation_client_name` [String] Client used to connect to the chef server API (e.g. teemo) Default: knife configuration
* `chef.validation_key_path` [String] Path to the validator client key (e.g. riot-validator.pem) Default: knife configuration
* `chef.node_name` [String] Node name used to authenticate with the chef server API (e.g. teemo) Default: knife configuration
* `chef.client_key` [String] Path to the key used to authenticate with the chef server API (e.g. teemo.pem) Default: knife configuration
* `cookbook.copyright` [String] Copyright holder to be used in Berkshelf generated cookbooks (e.g. Riot Games) Default: YOUR_NAME
* `cookbook.email` [String] Email address for the maintainer of Berkshelf generated cookbooks (e.g. teemo@riotgames.com) Default: YOUR_EMAIL
* `cookbook.license` [String] Licence to be used in Berkshelf generated cookbooks (e.g. MIT) Default: reserved
* `allowed_licenses` [Array] List of licences allowed to be used in cookbooks (e.g. [ "MIT", "Apache" ]) Default: []
* `raise_license_exception` [Boolean] Raise an exception if the license used in a dependent cookbook resolved by Berkshelf is not in the list of allowed licenses defined in allowed_licenses (e.g. true) Default: false
* `vagrant.vm.box` [String] Name of the box printed in a Vagrantfile's config.vm.box field (e.g. arbitrary_box_name) Default: 'opscode_ubuntu-12.04_provisionerless'
* `vagrant.vm.box_url` [String] Download URL for the box referred to in vagrant.vm.box Default: https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box
* `vagrant.vm.forward_port` [Hash] Set of key/value pairs (mapping to guest/host, respectively) specifying which ports the Vagrantfile should configure to be forwarded. (e.g. {"80": "8080"})
* `vagrant.vm.network.bridged` [Boolean] Whether the network should be configured to "bridged" in the Vagrantfile (e.g. true) Default: false
* `vagrant.vm.network.hostonly` [String] Default IP address to be configured in the Vagrantfile (e.g. 172.10.10.11) Default: 33.33.33.10
* `vagrant.vm.provision` [String] The default provisioner to use in the Vagrantfile (e.g. chef_client) Default: chef_solo
* `vagrant.omnibus.enabled` [Boolean] Whether the omnibus vagrant plugin should be used to install Chef on the VM (e.g. false) Default: true
* `vagrant.omnibus.version` [String] The version of Chef the omnibus installer should install on teh VM (e.g. 11.6.0) Default: latest
* `ssl.verify` [Boolean] Whether to verify the SSL certificate used by resources Berkshelf connects to. If your Chef server uses a self signed certificate, this should be false. (e.g. false) Default: true

> The configuration values are notated in 'dotted path' format. These translate to a nested JSON structure, for example:
>`a.b.c = 'val'` maps to `{"a": {"b": {"c": "val"} } }`

## Vagrant with Berkshelf

Berkshelf was designed for iterating on cookbooks and applications quickly. [Vagrant](http://vagrantup.com) provides us with a way to spin up a virtual environment and configure it using a built-in Chef provisioner. If you have never used Vagrant before - stop now - read the [Vagrant documentation](http://docs.vagrant.com) and give it a try. Your cookbook development life is about to become 100% better.

If you have used Vagrant before, READ ON!

### Install Vagrant

Visit the [Vagrant downloads page](http://downloads.vagrantup.com/) and download the latest installer for your operating system.

### Install the Vagrant Berkshelf plugin

There is a separate gem which provides the [Vagrant Berkshelf plugin](https://github.com/riotgames/vagrant-berkshelf). This plugin supports Vagrant 1.1.0 and greater.

To install the plugin run the Vagrant plugin install command

    $ vagrant plugin install vagrant-berkshelf
    Installing the 'vagrant-berkshelf' plugin. This can take a few minutes...
    Installed the plugin 'vagrant-berkshelf (1.4.0)!'

### Using the Vagrant Berkshelf plugin

Once the Vagrant Berkshelf plugin is installed it can be enabled in your Vagrantfile

    Vagrant.configure("2") do |config|
      ...
      config.berkshelf.enabled = true
      ...
    end

> If your Vagrantfile was generated by Berkshelf it will be enabled by default

The plugin will look in your current working directory for your `Berksfile` by default. Ensure that your Berksfile exists and when you run `vagrant up`, `vagrant provision`, or `vagrant destroy` the Berkshelf integration will automatically kick in!

    $ vagrant provision
    [Berkshelf] Updating Vagrant's berkshelf: '/Users/teemo/.berkshelf/vagrant/berkshelf-20130320-28478-sy1k0n'
    [Berkshelf] Installing nginx (2.0.0)
    ...

You can use both the Vagrant provided Chef Solo and Chef Client provisioners with the Vagrant Berkshelf plugin.

#### Chef Solo provisioner

The Chef Solo provisioner's `cookbook_path` attribute is hijacked when using the Vagrant Berkshelf plugin. Cookbooks resolved from your Berksfile will automatically be made available to your Vagrant virtual machine. There is no need to explicitly set a value for `cookbook_path` attribute.

#### Chef Client provisioner

Cookbooks will automatically be uploaded to the Chef Server you have configured in the Vagrantfile's Chef Client provisioner block. Your Berkshelf configuration's `chef.node_name` and `chef.client_key` credentials will be used to authenticate the upload.

#### Setting a Berksfile location

By default, the Vagrant Berkshelf plugin will assume that the Vagrantfile is located in the same directory as a Berksfile. If your Berksfile is located in another directory you can override this behavior

    Vagrant.configure("2") do |config|
      ...
      config.berkshelf.berksfile_path = "/Users/teemo/code/mushroom/Berksfile"
    end

The above example will use an absolute path to the Berksfile of a sweet application called Mushroom.

## The Berksfile

Dependencies are managed via the file `Berksfile`. The Berksfile contains a list of cookbooks to retrieve and where to get them.

    metadata
    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'pvpnet', path: '/Users/teemo/code/riot-cookbooks/pvpnet-cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'
    cookbook 'database', github: 'opscode-cookbooks/database'
    cookbook 'myapp', chef_api: :config

All listed dependencies _and_ their dependencies will be retrieved, recursively. Two kinds of dependency can be defined.

### Cookbook

The usual way to define a cookbook dependency is with a `cookbook` statement in your Berksfile. They have the format:

    cookbook {name}, {version_constraint}, {options}

The first parameter is the `name` and is the only required parameter

    cookbook "nginx"

The second parameter is a `version constraint` and is optional. If no version constraint is specified the latest is assumed

    cookbook "nginx", ">= 2.0.0"

[Constraints](http://docs.opscode.com/essentials_cookbook_versions.html) can be specified as

* Equal to (=)
* Greater than (>)
* Greater than or equal to (>=)
* Less than (<)
* Less than or equal to (<=)
* Approximately greater than (~>)

The final parameter is an options hash

### Metadata

Defining a dependency via metadata says, "There is a metadata.rb file within the same relative path of my Berksfile". This allows you to resolve a Cookbook's dependencies that you are currently working.

Given a Berksfile at `~/code/nginx-cookbook` containing:

    metadata

A `metadata.rb` file is assumed to be located at `~/code/nginx-cookbook/metadata.rb` describing your nginx cookbook.

### Sources

Berkshelf comes configured with one source of cookbook metadata: api.berkshelf.com contains a list of all cookbooks available on the Opscode Community Site and their dependencies. You do not need to configure anything to use cookbooks from this source.

If you want to use another source of cookbook metadata, it's easy to do so. You must also include api.berkshelf.com if you specify any other sources - once you start configuring it, Berkshelf assumes you may not want the defaults at all.

    source "https://api.berkshelf.com"
    source "https://berks-api.intranet.riotgames.com"

For more information about running your own [Berkshelf API](https://github.com/RiotGames/berkshelf-api) server, see the [RiotGames/berkshelf-api](https://github.com/RiotGames/berkshelf-api) on GitHub.

### Dependency Options

Options passed to a cookbook dependency can contain a location or a group(s).

#### Locations

By default a cookbook will be downloaded from the API source that provided it, defaulting the the Opscode Community site `http://cookbooks.opscode.com/api/v1/cookbooks`. You might want to use a different location type if the cookbook is stored in a git repository or a local file path.

##### Path Location

The Path location is useful for rapid iteration because it does not download, copy, or move the cookbook to The Berkshelf or change the contents of the target. Instead the cookbook found at the given filepath will be used alongside the cookbooks found in The Berkshelf.

    cookbook "artifact", path: "/Users/teemo/code/artifact-cookbook"

The value given to `:path` can only contain a single cookbook and _must_ contain a `metadata.rb` file.

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

Adding dependencies to a group is useful if you want to ignore a cookbook or a set of cookbooks at install or upload time.

Groups can be defined via blocks:

    group :solo do
      cookbook 'riot_base'
    end

Groups can also be defined inline as an option:

    cookbook 'riot_base', group: 'solo'

To exclude the groups when installing or updating just add the `--without` flag.

    $ berks install --without solo

## Generating a New Cookbook

Berkshelf includes a command to help you quickly generate a cookbook with a number of helpful supporting tools

    $ berks cookbook mushroom --foodcritic

This will generate a cookbook called "mushroom" in your current directory with Vagrant, Git, and Foodcritic support. Check out [this guide](http://vialstudios.com/guide-authoring-cookbooks.html) for more information and the help provided in the Berkshelf CLI for the cookbook command.

## Build Integration

Instead of invoking Berkshelf directly on the command-line, you can also run Berkshelf from within a Thor process.

### Thor

Just add the following line to your Thorfile:

    require 'berkshelf/thor'

Now you have access to common Berkshelf tasks without shelling out

    $ thor list

    $ berkshelf
    $ ---------
    $ thor berkshelf:init [PATH]  # Prepare a local path to have it's Cook...
    $ thor berkshelf:install      # Install the Cookbooks specified by a B...
    $ thor berkshelf:update       # Update all Cookbooks and their depende...
    $ thor berkshelf:upload       # Upload the Cookbooks specified by a Be...
    $ thor berkshelf:version      # Display version and copyright informat...
