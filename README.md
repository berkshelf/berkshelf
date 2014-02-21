Berkshelf
=========
[![Gem Version](https://badge.fury.io/rb/berkshelf.png)](http://badge.fury.io/rb/berkshelf)
[![Build Status](https://travis-ci.org/berkshelf/berkshelf.png?branch=master)](https://travis-ci.org/berkshelf/berkshelf)

Manage a Cookbook or an Application's Cookbook dependencies

Installation
------------

**WARNING:** It is advised at this time that you [use Berkshelf 3](https://github.com/berkshelf/berkshelf/wiki/Howto:-Use-the-bleeding-edge). Berkshelf 2 is no longer being actively developed and has a number of significant issues related to dependency resolution that Berkshelf 3 fixes.

Add Berkshelf to your repository's `Gemfile`:

```ruby
gem 'berkshelf'
```

Or run it as a standalone:

    gem install berkshelf

Usage
-----
See [berkshelf.com](http://berkshelf.com) for up-to-date usage instructions.

Supported Platforms
-------------------
Berkshelf is tested on Ruby 1.9.3, 2.0.0, and JRuby 1.6+.

Ruby 1.9 mode is required on all interpreters.

Ruby 1.9.1 and 1.9.2 are not officially supported. If you encounter problems, please upgrade to Ruby 2.0 or 1.9.3.

Bash & Zsh Completion
---------------
There is a [berkshelf bash completion script](https://raw.github.com/berkshelf/berkshelf/master/berkshelf-complete.sh). If you're using homebrew, you can install it like this:

    brew install bash-completion # if you haven't already

Download the latest script

    (cd `brew --prefix`/etc/bash_completion.d && curl https://raw.github.com/berkshelf/berkshelf/master/berkshelf-complete.sh > berkshelf-complete.sh)

And make sure you have this in your bash/zsh profile:

    [ -f `brew --prefix`/etc/bash_completion ] && source `brew --prefix`/etc/bash_completion

If you prefer zsh, there is an [oh-my-zsh plugin](https://github.com/berkshelf/berkshelf-zsh-plugin) for command completion. Check the [README](https://github.com/berkshelf/berkshelf-zsh-plugin/blob/master/README.md) for details.

Plugins
-------
Please see [Plugins page](https://github.com/berkshelf/berkshelf/blob/master/PLUGINS.md) for more information.

Configuration
-------------
Berkshelf will search in specific locations for a configuration file. In order:

```text
$PWD/.berkshelf/config.json
$PWD/berkshelf/config.json
$PWD/berkshelf-config.json
$PWD/config.json
~/.berkshelf/config.json
```

You are encouraged to keep project-specific configuration in the `$PWD/.berkshelf` directory. A default configuration file is generated for you, but you can update the values to suit your needs.

SSL Errors
----------

If you have trouble getting Berkshelf to successfully talk to an SSL Chef Server, you can try making sure you
have a certificate bundle available to your shell. `export SSL_CERT_FILE=...path/to/cert/file...`

If you need to disable SSL, you can in `~/.berkshelf/config.json` like so:

```
{
  "ssl": {
    "verify": false
  }
}
```

Authors
-------
- Jamie Winsor (<jamie@vialstudios.com>)
- Josiah Kiehl (<jkiehl@riotgames.com>)
- Michael Ivey (<michael.ivey@riotgames.com>)
- Justin Campbell (<justin@justincampbell.me>)
- Seth Vargo (<sethvargo@gmail.com>)

Thank you to all of our [Contributors](https://github.com/berkshelf/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/berkshelf/berkshelf/blob/master/CONTRIBUTING.md) first.
