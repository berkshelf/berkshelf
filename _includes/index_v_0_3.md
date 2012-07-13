## Getting Started

If you're familiar with [Bundler](http://gembundler.com), then Berkshelf is a breeze.

    $ gem install berkshelf

Specify your dependencies in a Berksfile in your application or cookbook's root

    cookbook 'mysql'
    cookbook 'nginx', '~> 0.101.5'

Install the cookbooks you specified in the Berksfile and their dependencies

    $ berks install

Add the Berksfile to your project

    $ git add Berksfile
    $ git commit -m "add Berksfile to project"

> A Berksfile.lock will also be created. Add this to version control if you want to ensure that
> other developers (or your build server) will use the same versions of all cookbook dependencies.

## The Berkshelf

> After running `berks install` you may ask yourself, "Where did my cookbooks go?". They were added to The Berkshelf.

The Berkshelf is a location on your local disk which contains the cookbooks you have installed and their dependencies. By default, The Berkshelf is located at `~/.berkshelf` but this can be altered by setting the environment variable `BERKSHELF_PATH`.

Berkshelf stores every version of a cookbook that you have ever installed. This is the same pattern found with RubyGems where once you have resolved and installed a gem, you will have that gem and it's dependencies until you delete it.

This central location is not the typical pattern of cookbook storage that you may be used to with Chef. The traditional pattern is to place all of your cookbooks in a directory called `cookbooks` or `site-cookbooks` within your [Chef Repository](http://wiki.opscode.com/display/chef/Chef+Repository). We do have all of our cookbooks in one central place, it's just not the Chef Repository and they're stored within directories named using the convention `{name}-{version}`.

Given you have the cookbooks installed:

    * nginx - 0.101.2
    * mysql - 1.2.4

These cookbooks will be located at:

    ~/.berkshelf/nginx-0.101.2
    ~/.berkshelf/mysql-1.2.4

By default Chef interprets the name of a cookbook by the directory name. Some Chef internals weigh the name of the directory more heavily than if a cookbook developer were to explicitly set the `name` attribute in their metadata. Because the directory structure contains the cookbook's version number, do not treat The Berkshelf as just another entry in your `Chef::Config#cookbooks_path`.

## Vagrant with Berkshelf 

Berkshelf was designed for iterating on cookbooks and applications quickly. [Vagrant](http://vagrantup.com) provides us with a way to spin up a virtual environment and configure it using a built-in Chef provisioner. If you have never used Vagrant before - stop now - read the Vagrant documentation and give it a try. Your cookbook development life is about to become 100% better.

If you have used Vagrant before, READ ON!

Because all cookbooks are stored in The Berkshelf, we need a way to present these cookbooks in the familiar structure that other tools expect. The typical pattern for having all cookbooks stored in the same directory with their folder names reflecting the name of the cookbook contained inside can be achieved easily with Berkshelf. Enter shims.

### shims

> a shim (from shim) or shiv is a small library that transparently intercepts 
> an API and changes the parameters passed, handles the operation itself, or 
> redirects the operation elsewhere.

Berkshelf handles shims by hard linking Cookbooks from The Berkshelf to a directory in your current working directory. You can install shims by adding the `--shims` flag to the install command.

    $ berks install --shims

Shims will be written to the directory `cookbooks` in your local working directory by default. A filepath can be provided to the `--shims` flag to customize this behavior.

    $ berks install --shims site-cookbooks

Given we have the following Berksfile:

    cookbook "nginx", "= 0.100.5"

Running the install command with the `--shims` flag would write the cookbook to `~/.berkshelf/nginx-0.100.5` and also create a shim at `cookbooks/nginx`.

In your Vagrant file you should add this shims directory to the `cookbooks_path`

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = [ "cookbooks" ]
    end

Now when we start our virtual machine it will have the cookbooks from The Berkshelf

    $ vagrant up

__Known Issue__: since shims are hard links to files on disk, changes to files will automatically be present in the shims directory. However, if a new file is added to a cookbook, it will not be present in the shims directory until the install command is run again.

## The Berksfile

Dependencies are managed via the file `Berksfile`. The Berksfile is like Bundler's Gemfile. Entries in the Berskfile are known as sources. It contains a list of sources identifying what Cookbooks to retrieve and where to get them.

    metadata
    cookbook 'memcached'
    cookbook 'nginx'
    cookbook 'pvpnet', path: '/Users/reset/code/riot-cookbooks/pvpnet-cookbook'
    cookbook 'mysql', git: 'git://github.com/opscode-cookbooks/mysql.git'

Two kinds of sources can be defined

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

##### Site Location

The Site location can be used to specify an alternate community site in the case where one other than the opscode provided one exists. For now, this is just present for completeness.

    cookbook "pvpnet", site: "http://cookbooks.opscode.com/api/v1/cookbooks"

##### Path Location

The Path location is useful for rapid iteration because it does not download, copy, or move the cookbook to The Berkshelf or change the contents of the target. Instead the cookbook found at the given filepath will be used alongside the cookbooks found in The Berkshelf.

    cookbook "pvpnet", path: "/Users/reset/code/pvpnet-cookbook"

The value given to `:path` should contain a single cookbook.

##### Git Location

The Git location will clone the given Git repository to The Berkshelf if the Git repository contains a valid cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git"

Given the previous example, the cookbook found at the HEAD revision of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

An optional `branch` key can be specified whose value is a tag, branch, or ref that contains the desired cookbook.

    cookbook "mysql", git: "https://github.com/opscode-cookbooks/mysql.git", branch: "1.0.1"

Given the previous example, the cookbook found at tag `1.0.1` of the opscode-cookbooks/mysql Github project will be cloned to The Berkshelf.

### Groups

Adding sources to a group is useful if you want to ignore a cookbook or a set of cookbooks at install or upload time.

Groups can be defined via blocks:

    group :solo do
      cookbook 'riot_base'
    end

Groups can also be defined inline as an option:
    
    cookbook 'riot_base', :group => 'solo'

To exclude the groups when installing or updating just add the `--without` flag.

    $ berks install --without solo

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

Prepares a local path to have it's Cookbook dependencies managed by Berkshelf. If the target path is a Cookbook itself, additional Berkshelf support files will be generated to get you started.

    $ berks init nginx-cookbook
