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

Authors
-------
- Jamie Winsor (<reset@riotgames.com>)
- Josiah Kiehl (<jkiehl@riotgames.com>)
- Michael Ivey (<michael.ivey@riotgames.com>)
- Justin Campbell (<justin.campbell@riotgames.com>)

Thank you to all of our [Contributors](https://github.com/RiotGames/berkshelf/graphs/contributors), testers, and users.

If you'd like to contribute, please see our [contribution guidelines](https://github.com/RiotGames/berkshelf/blob/master/CONTRIBUTING.md) first.
