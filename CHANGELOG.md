> This is a high level digest of changes. For the complete CHANGELOG diff two tags in the project's [commit history](https://github.com/berkshelf/berkshelf/commits/master).

# 4.0.1

* Update `berkshelf-api-client` constraint to `~> 2.0`

# 4.0.0

* Drop support for Ruby 1.9
* Switch from `net_http_client` to `httpclient` Faraday adapter for all HTTP communication

# 3.3.0

* Enhancements
  * Use [httpclient](https://github.com/nahi/httpclient) in place of Ruby stdlib NetHTTP for http communication
  * Clarify decompression error messages

# 3.2.4

* Bug Fixes
  * Fix issue where older version of a cookbook would be presented as the latest available version from a remote API server's cache
  * Exclude git directories when vendoring
  * Fix a race condition in downloading cookbooks from Github or a URI location

# 3.2.3

* Bug Fixes
  * Specifying the --skip-syntax-check flag to upload will once again cause validations to be skipped

# 3.2.2

* Enhancements
  * Use chef.io hostname in urls instead of getchef

* Bug Fixes
  * Fix syntax issue in generated Vagrantfile
  * Only exclude the top level metadata.rb file when vendoring cookbooks rather than all files named metadata.rb
  * Relative paths can now be passed to berks vendor

# 3.2.1

* Bug Fixes
  * Fix issue with copying raw metadata when vendoring / packaging.
  * Berkshelf should cleanup any temporary directories it creates. There is still work to be done in any of Berkshelf's dependencies.

# 3.2.0

* Improvements
  * Add version information to edges of generated visualization graph
  * Bump to latest full release of Celluloid
  * Updated some errors to include more information about what went wrong / how to make it better
  * Lockfiles will be named after the name of the Berksfile, not always Berksfile.lock
  * Vendoring will now sync files between two directories instead of deleting the target and it's contents
  * Add support for downloading from Berkshelf-API file_store location
  * Add `berks verify` command to validate Ruby syntax, ERB templates, and file names of cookbooks

* Bug Fixes
  * Fixed a number of typos and documentation errors
  * Fix running `berks viz` when pwd has spaces in it
  * Fix checking for graphviz on Windows
  * Remove PaxHeader files before uploading
  * BERKSHELF_PATH will always be fully expanded regardless of how it is configured

* Deprecations
  * vagrant.omnibus.enabled configuration option is now deprecated

# 3.1.5

* Bug Fixes
  * Supermarket endpoint is now an alias for Opscode endpoint
  * Set proper default value for supermarket api endpoint

# 3.1.4

* Improvements
  * Update the default vagrant box from the generators to Ubuntu 14.04 (formerly 12.04 EOL)

* Bug Fixes
  * Handle the case where a remote source had been removed but still existed in the lockfile
  * Follow redirects (HTTP -> HTTPS) in all requests

# 3.1.3

* Enhancements
  * Updated out of date dependencies

* Bug Fixes
  * Skip loading of cached cookbooks that do not have a value for metadata
  * SSL Verify option will be respected when communicating to an API server
  * Fixed issue where some commands were unexpectedly crashing instead of informing the user that Git is not installed

# 3.1.2

* Enhancements
  * SCM history is now stripped from cookbooks retrieved from an SCM location which will conserve disk space for cookbooks with a large history
* Bug Fixes
  * Fix formatting issue with console output on some systems
  * Handle crash on install on some machines which do not properly report their number of CPU cores
  * Fix infinite loop in checking if the lockfile is synced under certain conditions
  * Fix console output crash on Windows
  * Fix issue where updating a cookbook would result in a non resolvable lockfile
  * Various spelling mistakes in console output

# 3.1.1

* Bug Fixes
  * Fix issue reading metadata which was compiled using an older (bugged) version of Knife
  * Fix issue with incorrectly reporting outdated cookbooks with the outdated command
  * Fix issue uploading some cookbooks which were generated with older metadata

# 3.1.0

* Enhancements
  * Added `berks viz` command which will output a visualized dependency graph
  * Added `berks info` command which outputs what `berks show` used to output
  * Changed `berks show` command to output the filepath where the cookbook is found
  * Improve error output when a solution couldn't be found

* Bug Fixes
  * Various documentation updates
  * Update description of version command

# 3.0.1

* Bug Fixes
  * Installation will no longer fail on machines with just 1 or 2 cores

# 3.0.0

* Enhancements
  * New "universe" resolver which communicates with an API server to resolve constraint graphs faster and more reliably
  * `berks vendor` will now compile cookbook metadata into the cookbook's vendored directory. The raw metadata will not be included in the vendored cookbook to ensure that Chef Client doesn't (wrongly) prioritize the raw metadata over compiled metadata
  * `berks vendor` now includes the Berksfile.lock alongside the vendored contents
  * `berks package` will now simply archive the output of `berks vendor`

* Bug Fixes
  * Raw metadata will be compiled into metadata.json during vendor process

* Backwards incompatible changes
  * `berks package` has had it's argument and options list updated. The first argument is now the name, or fulle path, of the archive file that will be generated. As with before, the first argument is not required.

# 2.0.16

* Update constraint on Ridley

# 2.0.14

* Backport changes from master to allow detecting cookbooks by metadata.json

# 2.0.13

* Lock transitive dependency on Faraday

# 2.0.10

* Huge performance increase when resolving a Berksfile when the Berkshelf contains a lot of cookbooks

# 2.0.9

* Update required version of Ridley

# 2.0.8

* Account for API changes to solve
* Rescue exceptions when parsing the lockfile
* Fix deprecation errors

# 2.0.7

* Fix crash when parsing a lockfile that contains path locations which no longer exist

# 2.0.6

* Fix installation failures due to latest release of ActiveSupport
* --except and --only will now work with a lockfile present

# 2.0.5

* Improve speed of resolution when a lockfile is present
* Gracefully fail when a lockfile is present but empty
* Fix issue where locked version was not honored if the cookbook store was empty

# 2.0.4

* Fix bug where community cookbooks compressed with bzip2 would not download and install
* Fix bug regression in Git caching which was previously fixed in 1.4.4
* Fix validation bug where a cookbook would be considered invalid if any spaces were present in the path to the directory containing the cookbook
* Fix issues with uploading cookbooks on Windows

# 2.0.3

* Fix issue where groups defined in the Berksfile would not be evaluated

# 2.0.2

* Fix issue with shellout on Windows. This would effect uploads and downloads of cookbooks using the Git location.
* The Berksfile DSL now evaluates in a clean room to prevent end-users from calling restricted methods.
* Fix issue with `berks upload -D` not properly skipping dependencies
* Added friendly error message when an unknown license is chosen during cookbook generation

# 2.0.1

* Improve performance of `berks upload`. It will now properly respect the Lockfile
* Fix debug/verbose logging
* You can now specify an alternate configuration with -c once again

# 2.0.0

* Huge improvements to the Lockfile
  - They actually work!
  - Now in JSON format
  - Old lockfiles will automatically be converted to the new format
* Add `berks shelf` command. Any operations on the already installed cookbooks now reside here
  - `berks shelf list` to list all cookbooks in the Berkshelf
  - `berks shelf show` to display information about a specific cookbook in the Berkshelf
  - `berks shelf uninstall` to remove an installed cookbook from the Berkshelf
* Add `berks package` command. Will package any cookbooks and dependencies defined in your Berksfile into a tar.
* Add `berks apply` command. Take the locked constraints of your lockfile and apply them directly to the an environment's locked cookbook versions.
* Test-Kitchen integration (beta)
  - Add `berks test` command. This is a delegator to `bin/kitchen`
  - Berkshelf's Cookbook generators will by default generate Test-Kitchen files for you
* Remove `berks open` command
* Rename `berks info` command to `berks show`

# 1.4.4

- Bump Ridley dependency to 0.12, bringing in many bugfixes.

# 1.4.3

- Bump Ridley dependency to 0.11, bringing in many bugfixes.

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
- Move Berkshelf Vagrant plugin into it's [own repository](https://github.com/berkshelf/vagrant-berkshelf)
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
