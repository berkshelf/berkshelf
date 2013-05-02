# 1.4.2

- Fix git caching bug for huge speedups in Berksfiles with lots of git
  paths. Thanks to @tylerflint and @jasondunsmore.

# 1.4.1

- Berksfile#upload will now honor the given server_url option
- Add validation to shortnames of 'site' in Berksfile
- Fix init generator issue by locking to the appropriate version of Rubygems

# 1.4.0

- Add ability to freeze cookbooks. Cookbooks are frozen on upload by default
- Add ability to forcefully upload cookbooks even if they are frozen with the `--force` option
- Add `berks info` command for displaying information about cookbooks in your Berkshelf
- Add `berks contingent` command for displaying a list of cookbooks which are dependent upon one another
- Cookbook generator now has the option of generating chef minispec files (false by default)
- Fix bug in downloading cookbooks which were packaged as plain tars instead of tar.gzs
- Path locations will now be relative to the Berksfile they are defined in

# 1.3.1
- Support for Vagrant 1.1.x
- Move Berkshelf Vagrant plugin into it's [own repository](https://github.com/RiotGames/berkshelf-vagrant)
- Added -d flag to output debug information in berks command
- Various bug fixes in uploading cookbooks

# 1.2.0
- Remove Vagrant as a gem dependency
- Remove Chef as a gem dependency
- Add retries to downloads/uploads
- Speed optimizations to resolver
- Speed optimizations to downloading cookbooks
- Speed optimizations to uploading cookbooks

# 1.1.0
## new/improved commands
- `berks show` command: display the file path for the given cookbook's current version resolved by your Berksfile
- `berks list` command: list all of the cookbooks and their versions that are installed by resolving your Berksfile
- `berks outdated` command (beta): show any cookbooks which have newer versions that are installed by resolving your Berksfile
- `berks open` command [alpha]: like `berks show` except used to open the cookbook in your configured editor
alpha: use at your own risk
- improved `berks upload` command: now takes an optional cookbook name, or names, which will upload the target cookbook(s) to the Chef Server
- improved `berks update` command: now takes an optional cookbook name, or names, which will update the target cookbook(s) in the Berksfile.lock

## bug fixes
- Improved error output in Vagrant plugin
- Stack traces will now be replaced by friendly error messages where possible
- Fix init generator on Ruby 1.9.2
- Honor 'chefignore' when vendoring cookbooks this will ensure that you aren't putting junk files into your cookbooks if your distributing them for use with Chef-Solo

# 1.0.0
- Windows support
- Easier installation by dropping Gecode requirement
- Vagrant plugin for a seamless iteration process
- Berkshelf has it's own configuration file
- `berks configure` command
- Github source location
- Improved upload/download speed of cookbooks
- Lots of bug fixes
