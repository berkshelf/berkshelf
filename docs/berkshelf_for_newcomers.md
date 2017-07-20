# Berkshelf for Newcomers

Berkshelf is a tool to help manage cookbook dependencies.  If your cookbook depends on other cookbooks, Berkshelf lets you do the following:

* download all cookbooks you depend on to your local machine for development and testing using `berks install`
* upload your cookbook and all dependencies to your Chef server using `berks upload`
* update your dependencies using `berks update`

The above are the main Berkshelf commands that will comprise the bulk of your workflow.

Berkshelf is included in the ChefDK (at least at v.0.10.0), and `chef generate cookbook` will set up your cookbook with the necessary files for Berkshelf usage.

## A quick example

Suppose you have a cookbook with the following `metadata.rb`:

```
name 'example_cookbook'
description 'Installs/Configures example_cookbook'
long_description 'Installs/Configures example_cookbook'
version '0.1.0'

depends 'apt', '~> 2.3'
```

To work on this cookbook locally, you need to download an `apt` cookbook matching the constraints.  Berkshelf handles this for you:

```
$ berks install
Resolving cookbook dependencies...
Fetching 'example_cookbook' from source at .
Fetching cookbook index from https://supermarket.chef.io...
Using example_cookbook (0.1.0) from source at .
Using apt (2.9.2)
```

When done your work, you need to push both your cookbook and the apt cookbook up to your Chef server.  With Berkshelf:

```
$ berks upload
Uploaded apt (2.9.2) to: 'https://your_chef_server_url'
Uploaded example_cookbook (0.1.0) to: 'your_chef_server_url'
```

The above is a trivial example.  If your cookbook has several dependencies, which in turn have dependencies, Berkshelf handles it all automatically, significantly improving your workflow.

## What's in the background

* the cookbook's `metadata.rb` specifies the cookbook dependencies and required versions
* the [Berksfile](https://docs.chef.io/berkshelf.html#the-berksfile) in your cookbook's root directory tells Berkshelf where to find cookbooks.  You can have multiple sources, or can pull individual cookbooks from specific locations, such as your own Supermarket, GitHub, or a file server.
* `berks install` downloads cookbooks and their dependencies to the [Berkshelf](https://docs.chef.io/berkshelf.html#berkshelf-cli), a place on your local disk.
* a Berksfile.lock is generated on `berks install` which specifies the exact cookbook versions that were used at that point

## Cookbook versioning

Berkshelf relies on cookbook versioning to work correctly.  A cookbook's version is tracked in its `metadata.rb`, and should follow the guidelines outlined at http://semver.org/.

# Further reading

* https://docs.chef.io/berkshelf.html

--

Good luck with Berkshelf!
