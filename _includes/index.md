## Getting Started

If you're familiar with [Bundler](http://gembundler.com), then Berkshelf is a breeze.

    $ gem install berkshelf
    Successfully installed berkshelf-1.3.0
    1 gem installed

Specify your dependencies in a Berksfile in your cookbook's root

    site :opscode

    cookbook 'mysql'
    cookbook 'nginx', '~> 0.101.5'

Install the cookbooks you specified in the Berksfile and their dependencies

    $ berks install

Add the Berksfile to your project

    $ git add Berksfile
    $ git commit -m "add Berksfile to project"

> A Berksfile.lock will also be created. Add this to version control if you want to ensure that
> other developers (or your build server) will use the same versions of all cookbook dependencies.

### Managing an existing Cookbook

If you already have a cookbook and it's not managed by Berkshelf it's easy to get up and running. Just locate your cookbook and initialize it!

    $ berks init ~/code/my_face-cookbook

### Creating a new Cookbook

Want to start a new cookbook for a new application or supporting application?

    $ berks cookbook new_application

## The Berkshelf

> After running `berks install` you may ask yourself, "Where did my cookbooks go?". They were added to The Berkshelf.

The Berkshelf is a location on your local disk which contains the cookbooks you have installed and their dependencies. By default, The Berkshelf is located at `~/.berkshelf` but this can be altered by setting the environment variable `BERKSHELF_PATH`.

Berkshelf stores every version of a cookbook that you have ever installed. This is the same pattern found with RubyGems where once you have resolved and installed a gem, you will have that gem and it's dependencies until you delete it.

This central location is not the typical pattern of cookbook storage that you may be used to with Chef. The traditional pattern is to place all of your cookbooks in a directory called `cookbooks` or `site-cookbooks` within your [Chef Repository](http://wiki.opscode.com/display/chef/Chef+Repository). We do have all of our cookbooks in one central place, it's just not the Chef Repository and they're stored within directories named using the convention `{name}-{version}`.

Given you have the cookbooks installed:

    * nginx - 0.101.2
    * mysql - 1.2.4

These cookbooks will be located at:

    ~/.berkshelf/cookbooks/nginx-0.101.2
    ~/.berkshelf/cookbooks/mysql-1.2.4

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

    Config written to: '/Users/reset/.berkshelf/config.json'

You will only be prompted to fill in the most travelled configuration options. Looking in the generated configuration will give you some insight to some other configurable values.

    {
      "chef": {
        "chef_server_url": "https://api.opscode.com/organizations/vialstudios",
        "validation_client_name": "chef-validator",
        "validation_key_path": "/etc/chef/validation.pem",
        "client_key": "/Users/reset/.chef/reset.pem",
        "node_name": "reset"
      },
      "vagrant": {
        "vm": {
          "box": "Berkshelf-CentOS-6.3-x86_64-minimal",
          "box_url": "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box",
          "forward_port": {

          },
          "network": {
            "bridged": true,
            "hostonly": "33.33.33.10"
          },
          "provision": "chef_solo"
        }
      },
      "ssl": {
        "verify": true
      }
    }

### Configurable options

* `chef.chef_server_url` - URL to a Chef Server API endpoint. This will automatically be filled in by your Knife configuration if you have one.
* `chef.node_name` - your Chef API client name. This will automatically be filled in by your Knife configuration if you have one.
* `chef.client_key` - filepath to your Chef API client key. This will automatically be filled in by your Knife configuration if you have one.
* `chef.validation_client_name` - your Chef API's validation client name. This will automatically be filled in by your Knife configuration if you have one.
* `chef.validation_key_path` - filepath to your Chef API's validation key. This will automatically be filled in by your knife configuration if you have one.
* `vagrant.vm.box` - name of the VirtualBox box to use when provisioning Vagrant virtual machines.
* `vagrant.vm.box_url` - URL to the VirtualBox box
* `vagrant.vm.forward_port` - a Hash of ports to forward where the key is the port to forward to on the guest and value is the host port which forwards to the guest on your host.
* `vagrant.vm.network.bridged` - use a bridged connection to connect to your virtual machine?
* `vagrant.vm.network.hostonly` - use a hostonly network for your virtual machine?
* `vagrant.vm.provision` - use the `chef_solo` or `chef_client` provisioner?
* `ssl.verify` - should we verify all SSL http connections?

> The configuration values are notated in 'dotted path' format. These translate to a nested JSON structure.

## Vagrant with Berkshelf

Berkshelf was designed for iterating on cookbooks and applications quickly. [Vagrant](http://vagrantup.com) provides us with a way to spin up a virtual environment and configure it using a built-in Chef provisioner. If you have never used Vagrant before - stop now - read the Vagrant documentation and give it a try. Your cookbook development life is about to become 100% better.

If you have used Vagrant before, READ ON!

### Install Vagrant

Visit the [Vagrant downloads page](http://downloads.vagrantup.com/) and download the latest installer for your operating system.

### Install the Berkshelf Vagrant plugin

As of Berkshelf 1.3.0 there is now a separate gem which includes the [Berkshelf Vagrant plugin](https://github.com/riotgames/berkshelf-vagrant). This plugin supports Vagrant 1.1.0 and greater.

To install the plugin run the Vagrant plugin install command

    $ vagrant plugin install berkshelf-vagrant
    Installing the 'berkshelf-vagrant' plugin. This can take a few minutes...
    Installed the plugin 'berkshelf-vagrant (1.1.0)!'

### Using the Berkshelf Vagrant plugin

Once the Berkshelf Vagrant plugin is installed it can be enabled in your Vagrantfile

    Vagrant.configure("2") do |config|
      ...
      config.berkshelf.enabled = true
      ...
    end

> If your Vagrantfile was generated by Berkshelf it's probably already enabled

The plugin will look in your current working directory for your `Berksfile` by default. Just ensure that your Berksfile exists and when you run `vagrant up`, `vagrant provision`, or `vagrant destroy` the Berkshelf integration will automatically kick in!

    $ vagrant provision
    [Berkshelf] Updating Vagrant's berkshelf: '/Users/reset/.berkshelf/vagrant/berkshelf-20130320-28478-sy1k0n'
    [Berkshelf] Installing nginx (1.2.0)
    ...

You can use both the Vagrant provided Chef Solo and Chef Client provisioners with the Berkshelf Vagrant plugin.

#### Chef Solo provisioner

The Chef Solo provisioner's `cookbook_path` attribute is hijacked when using the Berkshelf Vagrant plugin. Cookbooks resolved from your Berksfile will automatically be made available to your Vagrant virtual machine. There is no need to explicitly set a value for `cookbook_path` attribute.

#### Chef Client provisioner

Cookbooks will automatically be uploaded to the Chef Server you have configured in the Vagrantfile's Chef Client provisioner block. Your Berkshelf configuration's `chef.node_name` and `chef.client_key` credentials will be used to authenticate the upload.

#### Setting a Berksfile location

By default, the Berkshelf Vagrant plugin will assume that the Vagrantfile is located in the same directory as a Berksfile. If your Berksfile is located in another directory you can override this behavior

    Vagrant.configure("2") do |config|
      ...
      config.berkshelf.berksfile_path = "/Users/reset/code/my_face/Berksfile"
    end

The above example will use an absolute path to the Berksfile of a sweet application called MyFace.

## The Berksfile

Dependencies are managed via the file `Berksfile`. The Berksfile is like Bundler's Gemfile. Entries in the Berskfile are known as sources. It contains a list of sources identifying what Cookbooks to retrieve and where to get them.

    metadata
    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'pvpnet', path: '/Users/reset/code/riot-cookbooks/pvpnet-cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'
    cookbook 'myapp', chef_api: :config

All sources _and_ their dependencies will be retrieved, recursively. Two kinds of sources can be defined.

### Metadata Source

The metadata source is like saying `gemspec` in Bundler's [Gemfile](http://gembundler.com/man/gemfile.5.html). It says, "There is a metadata.rb file within the same relative path of my Berksfile". This allows you to resolve a Cookbook's dependencies that you are currently working on just like you would resolve the dependencies of a Gem that you are currently working on with Bundler.

Given a Berksfile at `~/code/nginx-cookbook` containing:

    metadata

A `metadata.rb` file is assumed to be located at `~/code/nginx-cookbook/metadata.rb` describing your nginx cookbook.

### Cookbook Source

A cookbook source is a way to describe a cookbook to install or a way to override the location of a dependency.

Cookbook sources are defined with the format:

    cookbook {name}, {version_constraint}, {options}

The first parameter is the `name` and is the only required parameter

    cookbook "nginx"

The second parameter is a `version constraint` and is optional. If no version constraint is specified the latest is assumed

    cookbook "nginx", ">= 0.101.2"

Constraints can be specified as

* Equal to (=)
* Greater than (>)
* Greater than equal to (<)
* Less than (<)
* Less than equal to (<=)
* Pessimistic (~>)

The final parameter is an options hash

### Source Options

Options passed to a source can contain a location or a group(s).

#### Locations

By default a cookbook source is assumed to come from the Opscode Community site `http://cookbooks.opscode.com/api/v1/cookbooks`. This behavior can be customized with a different location type. You might want to use a different location type if the cookbook is stored in a git repository, at a local file path, or at a different community site.

##### Chef API Location

The Chef API location allows you to treat your Chef Server like an [artifact](http://en.wikipedia.org/wiki/Artifact_%28software_development%29) server. Cookbooks or dependencies can be pulled directly out of a Chef Server. This is super useful if your organization has cookbooks that isn't available to the community but may be a dependency of other proprietary cookbooks in your organization.

A Chef API Location is expressed with the `chef_api` key followed by some options. You can tell Berkshelf to use the Chef credentials found in your Berkshelf config by passing the symbol `:config` to `chef_api`.

    cookbook "artifact", chef_api: :config

The Berkshelf configuration is by default located at `~/.berkshelf/config.json`. You can specify a different configuration file with the `-c` flag.

    $ berks install -c /Users/reset/.berkshelf/production-config.json

You can also explicitly define the `chef_server_url`, `node_name`, and `client_key` to use:

    cookbook "artifact", chef_api: "https://api.opscode.com/organizations/vialstudios", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem"

##### Site Location

The Site location can be used to specify a community site API to retrieve cookbooks from

    cookbook "artifact", site: "http://cookbooks.opscode.com/api/v1/cookbooks"

The symbol `:opscode` is an alias for "Opscode's newest community API" and can be provided in place of a URL

    cookbook "artifact", site: :opscode

##### Path Location

The Path location is useful for rapid iteration because it does not download, copy, or move the cookbook to The Berkshelf or change the contents of the target. Instead the cookbook found at the given filepath will be used alongside the cookbooks found in The Berkshelf.

    cookbook "artifact", path: "/Users/reset/code/artifact-cookbook"

The value given to `:path` can only contain a single cookbook and _must_ contain a `metadata.rb` file.

##### Git Location

The Git location will clone the given Git repository to The Berkshelf if the Git repository contains a valid cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git"

Given the previous example, the cookbook found at the HEAD revision of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `branch` key can be specified whose value is a tag, branch, or ref that contains the desired cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", branch: "1.0.1"

Given the previous example, the cookbook found at tag `1.0.1` of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `rel` key can be specified if your repository contains many cookbooks in a single repository under a sub-directory or at root.

    cookbook "rightscale", git: "https://github.com/rightscale/rightscale_cookbooks.git", rel: "cookbooks/rightscale"

This will fetch the cookbook `rightscale` from the speficied Git location from under the `cookbooks` sub-directory.

##### GitHub Location

As of version 1.0.0, you may now use GitHub shorthand to specify a location.

    cookbook "artifact", github: "RiotGames/artifact-cookbook", ref: "0.9.8"

Given this example, the `artifact` cookbook from the `RiotGames` organization in the `artifact-cookbook` repository with a tag of `0.9.8` will be cloned to The Berkshelf.

Note: `ref:` is an alias for `branch:` and can be used interchangeably.

The `git` protocol will be used if no protocol is explicity set. To access a private repository specify the `ssh` or `https` protocol.

    cookbook "keeping_secrets", github: "RiotGames/keeping_secrets-cookbook", protocol: :ssh

> You will receive a repository not found error if you are referencing a private repository and have not set the protocol to `https` or `ssh`.

### Default Locations

Any source that does not explicit define a location will attempted to be retrieved at the latest Opscode community API. Any source not explicitly defined in the Berksfile but found in the `metadata.rb` of the current cookbook or a dependency will also attempt to use this default location.

Additional site locations can be specified with the `site` keyword in the Berksfile

    site "http://cookbooks.opscode.com/api/v1/cookbooks"

This same entry could also have been written

    site :opscode

A Chef API default location can also be specified to attempt to retrieve your cookbook and it's dependencies from

    chef_api "https://api.opscode.com/organizations/vialstudios", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem"

Provided my Berkshelf config contains these Chef credentials - this could have been simplified by using the `:config` symbol

    chef_api :config

> Specifying a Chef API default location is particularly useful if you have cookbooks that are
> private to your organization that are not shared on the Opscode community site.
>
> It is highly recommended that you upload your cookbooks to your organization's Chef Server
> and then set a chef_api default location at the top of every application cookbook's Berksfile

#### Multiple default locations

A combination of default locations can be specified in case a location is unavailable or does not contain the desired cookbook or version

    chef_api :config
    site :opscode

    cookbook "artifact", "= 0.10.0"

The order in which the default locations keywords appear in the Berksfile is the order in which sources will be tried. In the above example Berkshelf would first try a Chef API using my Berkshelf configuration to find the "artifact" cookbook. If the Chef API didn't contain the "artifact" cookbook, or version 0.10.0 of the cookbook, it will try the Opscode community site.

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

## Generating a New Cookbook

Berkshelf includes a command to help you quickly generate a cookbook with a number of helpful supporting tools

    $ berks cookbook my_face --foodcritic

This will generate a cookbook called "my_face" in your current directory with Vagrant, Git, and Foodcritic support. Check out [this guide](http://vialstudios.com/guide-authoring-cookbooks.html) for more information and the help provided in the Berkshelf CLI for the cookbook command.

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

## CLI Reference

### install

Install the Cookbooks defined by sources in your Berksfile and their dependencies, recursively, to your Berkshelf.

    $ berks install

A Berksfile.lock will be generated if one does not already exist that will contain the dependency solution.

If a Berksfile.lock is present when the install command is run, the locked sources in the Lockfile will take precedence over any sources defined in the Berksfile.

### upload

Upload the Cookbooks specified by a Berksfile or a Berksfile.lock to a Chef Server.

    $ berks upload

### update

This will still perform an install on your Berksfile, but it will skip a Lockfile if it is present and install fresh

    $ berks update

### init

Prepares a local path to have its Cookbook dependencies managed by Berkshelf. If the target path is a Cookbook itself, additional Berkshelf support files will be generated to get you started.

    $ berks init nginx-cookbook

### Cookbook

Creates a new cookbook with a number of helpful supporting tools to help you iterate quickly and develop reliable cookbooks.

    $ berks cookbook my_face
