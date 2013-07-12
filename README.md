Berkshelf
=========
[![Gem Version](https://badge.fury.io/rb/berkshelf.png)](http://badge.fury.io/rb/berkshelf)
[![Build Status](https://travis-ci.org/RiotGames/berkshelf.png?branch=master)](https://travis-ci.org/RiotGames/berkshelf)
[![Dependency Status](https://gemnasium.com/RiotGames/berkshelf.png)](https://gemnasium.com/RiotGames/berkshelf)
[![Code Climate](https://codeclimate.com/github/RiotGames/berkshelf.png)](https://codeclimate.com/github/RiotGames/berkshelf)

Manage a Cookbook or an Application's Cookbook dependencies

Installation
------------
Add Berkshelf to your repository's `Gemfile`:

```ruby
gem 'berkshelf'
```

Or run it as a standalone:

    gem install berkshelf

Usage
-----
See [berkshelf.com](http://berkshelf.com) for up-to-date usage instructions.

Bash Completion
---------------
There is a [berkshelf bash completion script](https://raw.github.com/RiotGames/berkshelf/master/berkshelf-complete.sh). If you're using homebrew, you can install it like this:

    brew install bash-completion # if you haven't already

Download the latest script

    cd `brew --prefix`/etc/bash_completion && wget https://raw.github.com/RiotGames/berkshelf/master/berkshelf-complete.sh

And make sure you have this in your bash/zsh profile:

    [ -f `brew --prefix`/etc/bash_completion ] && source `brew --prefix`/etc/bash_completion

Plugins
-------
Please see [Plugins page](https://github.com/RiotGames/berkshelf/blob/master/PLUGINS.md) for more information.

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

You are encouraged to keep project-specific configuration in the `$PWD/.berkshelf` directory. You can generate a project-configuration file by running:

    $ berks configure --path ./.berkshelf/config.json

SSL Errors
----------

If you have trouble getting Berkshelf to successfully talk to an SSL Chef server, you can try making sure you
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
- Justin Campbell (<justin.campbell@riotgames.com>)
- Seth Vargo (<sethvargo@gmail.com>)

Thank you to all of our [Contributors](https://github.com/RiotGames/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/RiotGames/berkshelf/blob/master/CONTRIBUTING.md) first.
