Berkshelf Plugins
=================
This is a list of community-contributed plugins for Berkshelf. A few notes:

- Please do not open issues regarding a community plugin on Berkshelf. Create the issue on the plugin first please.
- Plugins are listed in alphabetical order for consistency.

Plugins
-------
- [berkshelf-shims](https://github.com/JeffBellegarde/berkshelf-shims) - Provide shims functionality for Berkshelf.
- [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf) - A Vagrant plugin to add Berkshelf integration to the Chef provisioners.

I want to add my plugin!
------------------------
1. Plugins should be prefixed with `berkshelf-` for consistency.
1. Create your plugin on github - be sure to include tests. We will most likely not list a plugin that is untested.
1. Fork the Berkshelf project on github.
1. Edit this file, adding your plugin. All plugins must be on github. The format for a plugin is:

        [Linked Project Name](#) - A short description of the plugin, what it does, why it exists, etc. ([Optional Link to Plugin Website](#))

  For example:

  [berkshelf-myface](https://github.com/RiotGames/berkshelf-myface) - A plugin to add myface support to Berkshelf.
