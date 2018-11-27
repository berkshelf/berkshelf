# Change Log

## [v7.0.7](https://github.com/berkshelf/berkshelf/tree/v7.0.7) (2018-11-27)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.3.4...v7.0.7)

**Merged pull requests:**

- Allow relative urls in location\_path for downloader [\#1799](https://github.com/berkshelf/berkshelf/pull/1799) ([DarthHater](https://github.com/DarthHater))
- Adds the possibility to show all outdated dependencies with berks outdated [\#1793](https://github.com/berkshelf/berkshelf/pull/1793) ([jeroenj](https://github.com/jeroenj))
- Remove chef from gemfile and add docs group [\#1792](https://github.com/berkshelf/berkshelf/pull/1792) ([tas50](https://github.com/tas50))

## [v6.3.4](https://github.com/berkshelf/berkshelf/tree/v6.3.4) (2018-08-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.6...v6.3.4)

**Merged pull requests:**

- \[SHACK-295\] Kitchen generator conflicts on 'chefignore' [\#1791](https://github.com/berkshelf/berkshelf/pull/1791) ([tyler-ball](https://github.com/tyler-ball))

## [v7.0.6](https://github.com/berkshelf/berkshelf/tree/v7.0.6) (2018-08-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.5...v7.0.6)

**Merged pull requests:**

- Use Strings to access options in try\_download. Fixes \#1764. [\#1782](https://github.com/berkshelf/berkshelf/pull/1782) ([xeron](https://github.com/xeron))

## [v7.0.5](https://github.com/berkshelf/berkshelf/tree/v7.0.5) (2018-08-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.3.3...v7.0.5)

**Merged pull requests:**

- Add a Chef::CookbookManifestVersions to RidleyCompat [\#1789](https://github.com/berkshelf/berkshelf/pull/1789) ([ryancragun](https://github.com/ryancragun))

## [v6.3.3](https://github.com/berkshelf/berkshelf/tree/v6.3.3) (2018-08-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.4...v6.3.3)

**Merged pull requests:**

- \[SHACK-295\] Missing require for ChefDK 2.x patch release [\#1788](https://github.com/berkshelf/berkshelf/pull/1788) ([tyler-ball](https://github.com/tyler-ball))
- Additional generator removal cleanup [\#1786](https://github.com/berkshelf/berkshelf/pull/1786) ([lamont-granquist](https://github.com/lamont-granquist))
- fixes for latest chefstyle updates [\#1784](https://github.com/berkshelf/berkshelf/pull/1784) ([lamont-granquist](https://github.com/lamont-granquist))
- remove hashrockets syntax [\#1783](https://github.com/berkshelf/berkshelf/pull/1783) ([lamont-granquist](https://github.com/lamont-granquist))

## [v7.0.4](https://github.com/berkshelf/berkshelf/tree/v7.0.4) (2018-06-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.3...v7.0.4)

**Merged pull requests:**

- Fix infinite loops in resolving cookbooks in the uploader [\#1781](https://github.com/berkshelf/berkshelf/pull/1781) ([lamont-granquist](https://github.com/lamont-granquist))

## [v7.0.3](https://github.com/berkshelf/berkshelf/tree/v7.0.3) (2018-06-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.2...v7.0.3)

**Merged pull requests:**

- stringify client\_key option before trying to match on it [\#1779](https://github.com/berkshelf/berkshelf/pull/1779) ([dbresson](https://github.com/dbresson))
- Provide the name during debug [\#1777](https://github.com/berkshelf/berkshelf/pull/1777) ([martinisoft](https://github.com/martinisoft))

## [v7.0.2](https://github.com/berkshelf/berkshelf/tree/v7.0.2) (2018-05-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.1...v7.0.2)

**Merged pull requests:**

- bump gems and update thor pin [\#1773](https://github.com/berkshelf/berkshelf/pull/1773) ([lamont-granquist](https://github.com/lamont-granquist))
- add support for lock bot [\#1772](https://github.com/berkshelf/berkshelf/pull/1772) ([lamont-granquist](https://github.com/lamont-granquist))
- remove dot dir from berks package [\#1771](https://github.com/berkshelf/berkshelf/pull/1771) ([lamont-granquist](https://github.com/lamont-granquist))

## [v7.0.1](https://github.com/berkshelf/berkshelf/tree/v7.0.1) (2018-05-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v7.0.0...v7.0.1)

**Merged pull requests:**

- fix reading the json config file [\#1770](https://github.com/berkshelf/berkshelf/pull/1770) ([lamont-granquist](https://github.com/lamont-granquist))
- CI fix:  remove '::' from module statements [\#1769](https://github.com/berkshelf/berkshelf/pull/1769) ([lamont-granquist](https://github.com/lamont-granquist))
- fix to generate metadata.json only in the vendored cookbook [\#1768](https://github.com/berkshelf/berkshelf/pull/1768) ([lamont-granquist](https://github.com/lamont-granquist))

## [v7.0.0](https://github.com/berkshelf/berkshelf/tree/v7.0.0) (2018-04-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.3.2...v7.0.0)

**Merged pull requests:**

- generate and upload metadata.json [\#1763](https://github.com/berkshelf/berkshelf/pull/1763) ([lamont-granquist](https://github.com/lamont-granquist))
- ship compiled metadata in the vendored cookbook [\#1760](https://github.com/berkshelf/berkshelf/pull/1760) ([lamont-granquist](https://github.com/lamont-granquist))
- Fix chefignores being ignored in berkshelf 7.0.0 [\#1758](https://github.com/berkshelf/berkshelf/pull/1758) ([lamont-granquist](https://github.com/lamont-granquist))
- pin cucumber-expressions to working version [\#1757](https://github.com/berkshelf/berkshelf/pull/1757) ([lamont-granquist](https://github.com/lamont-granquist))
- changelog update and bonus bump to Gemfile.lock [\#1756](https://github.com/berkshelf/berkshelf/pull/1756) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.3.2](https://github.com/berkshelf/berkshelf/tree/v6.3.2) (2018-04-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.3.1...v6.3.2)

**Merged pull requests:**

- remove buff-extensions [\#1747](https://github.com/berkshelf/berkshelf/pull/1747) ([lamont-granquist](https://github.com/lamont-granquist))
- remove buff-config / varia\_model [\#1746](https://github.com/berkshelf/berkshelf/pull/1746) ([lamont-granquist](https://github.com/lamont-granquist))
- ignore .svn recursively [\#1742](https://github.com/berkshelf/berkshelf/pull/1742) ([lamont-granquist](https://github.com/lamont-granquist))
- minitar update for security fixes [\#1741](https://github.com/berkshelf/berkshelf/pull/1741) ([lamont-granquist](https://github.com/lamont-granquist))
- remove direct use of faraday [\#1740](https://github.com/berkshelf/berkshelf/pull/1740) ([lamont-granquist](https://github.com/lamont-granquist))
- Update cookbook upload order [\#1735](https://github.com/berkshelf/berkshelf/pull/1735) ([shoekstra](https://github.com/shoekstra))
- remove deprecated features [\#1729](https://github.com/berkshelf/berkshelf/pull/1729) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.3.1](https://github.com/berkshelf/berkshelf/tree/v6.3.1) (2017-08-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.3.0...v6.3.1)

**Merged pull requests:**

- Bump solve to 4.0 [\#1726](https://github.com/berkshelf/berkshelf/pull/1726) ([thommay](https://github.com/thommay))
- Remove ridley as a dep of Berkshelf [\#1719](https://github.com/berkshelf/berkshelf/pull/1719) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.3.0](https://github.com/berkshelf/berkshelf/tree/v6.3.0) (2017-08-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.2.2...v6.3.0)

**Merged pull requests:**

- Remove stale comment [\#1724](https://github.com/berkshelf/berkshelf/pull/1724) ([jaym](https://github.com/jaym))
- Fix up Dir.glob for windows [\#1722](https://github.com/berkshelf/berkshelf/pull/1722) ([jaym](https://github.com/jaym))
- bump the gemfile.lock [\#1721](https://github.com/berkshelf/berkshelf/pull/1721) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.2.2](https://github.com/berkshelf/berkshelf/tree/v6.2.2) (2017-08-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.2.1...v6.2.2)

**Merged pull requests:**

- fix verify false and add tests [\#1720](https://github.com/berkshelf/berkshelf/pull/1720) ([lamont-granquist](https://github.com/lamont-granquist))
- Docs update [\#1715](https://github.com/berkshelf/berkshelf/pull/1715) ([iennae](https://github.com/iennae))

## [v6.2.1](https://github.com/berkshelf/berkshelf/tree/v6.2.1) (2017-07-18)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.2.0...v6.2.1)

**Merged pull requests:**

- remove berks-api dep [\#1712](https://github.com/berkshelf/berkshelf/pull/1712) ([lamont-granquist](https://github.com/lamont-granquist))
- pull berkshelf-api-client gem into berkshelf [\#1711](https://github.com/berkshelf/berkshelf/pull/1711) ([lamont-granquist](https://github.com/lamont-granquist))
- bump berkshelf-api-client dep to 4.0.1 [\#1710](https://github.com/berkshelf/berkshelf/pull/1710) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.2.0](https://github.com/berkshelf/berkshelf/tree/v6.2.0) (2017-06-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.1.1...v6.2.0)

**Merged pull requests:**

- pull in berkshelf-api-client and bump deps [\#1707](https://github.com/berkshelf/berkshelf/pull/1707) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.1.1](https://github.com/berkshelf/berkshelf/tree/v6.1.1) (2017-06-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.1.0...v6.1.1)

**Merged pull requests:**

- bumping cookstyle deps and others [\#1708](https://github.com/berkshelf/berkshelf/pull/1708) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.1.0](https://github.com/berkshelf/berkshelf/tree/v6.1.0) (2017-05-31)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.0.1...v6.1.0)

**Merged pull requests:**

- Release 6.1.0 [\#1704](https://github.com/berkshelf/berkshelf/pull/1704) ([thommay](https://github.com/thommay))
- remove TK dep and undocumented 'berks test' command [\#1702](https://github.com/berkshelf/berkshelf/pull/1702) ([lamont-granquist](https://github.com/lamont-granquist))
- remove direct use of buff-shell\_out [\#1701](https://github.com/berkshelf/berkshelf/pull/1701) ([lamont-granquist](https://github.com/lamont-granquist))
- guard seems to be a lot more trouble than its worth [\#1700](https://github.com/berkshelf/berkshelf/pull/1700) ([lamont-granquist](https://github.com/lamont-granquist))
- bump deps \(faraday+ridley\) [\#1699](https://github.com/berkshelf/berkshelf/pull/1699) ([lamont-granquist](https://github.com/lamont-granquist))
- replace celluloid with concurrent-ruby futures [\#1698](https://github.com/berkshelf/berkshelf/pull/1698) ([lamont-granquist](https://github.com/lamont-granquist))
- Switch off open-uri for community site downloads [\#1697](https://github.com/berkshelf/berkshelf/pull/1697) ([coderanger](https://github.com/coderanger))
- Add chef\_repo source [\#1696](https://github.com/berkshelf/berkshelf/pull/1696) ([coderanger](https://github.com/coderanger))
- Pass along an artifactory\_api\_key attribute from a Chef config [\#1693](https://github.com/berkshelf/berkshelf/pull/1693) ([RoboticCheese](https://github.com/RoboticCheese))
- add chefstyle enforcement [\#1663](https://github.com/berkshelf/berkshelf/pull/1663) ([lamont-granquist](https://github.com/lamont-granquist))

## [v6.0.1](https://github.com/berkshelf/berkshelf/tree/v6.0.1) (2017-05-17)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v6.0.0...v6.0.1)

**Merged pull requests:**

- update travis rvm versions [\#1692](https://github.com/berkshelf/berkshelf/pull/1692) ([thommay](https://github.com/thommay))

## [v6.0.0](https://github.com/berkshelf/berkshelf/tree/v6.0.0) (2017-05-17)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.5...v6.0.0)

**Merged pull requests:**

- Minor refactor on the default artifactory options and support artifactory\_api\_key in knife.rb [\#1691](https://github.com/berkshelf/berkshelf/pull/1691) ([coderanger](https://github.com/coderanger))
- Artifactory support [\#1690](https://github.com/berkshelf/berkshelf/pull/1690) ([coderanger](https://github.com/coderanger))

## [v5.6.5](https://github.com/berkshelf/berkshelf/tree/v5.6.5) (2017-05-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.4...v5.6.5)

**Merged pull requests:**

- handle Windows backslashes in trusted\_certs path [\#1689](https://github.com/berkshelf/berkshelf/pull/1689) ([jeremymv2](https://github.com/jeremymv2))

## [v5.6.4](https://github.com/berkshelf/berkshelf/tree/v5.6.4) (2017-03-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.3...v5.6.4)

**Merged pull requests:**

- Add Support for Auth Proxy [\#1684](https://github.com/berkshelf/berkshelf/pull/1684) ([tduffield](https://github.com/tduffield))

## [v5.6.3](https://github.com/berkshelf/berkshelf/tree/v5.6.3) (2017-02-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.2...v5.6.3)

**Merged pull requests:**

- Release 5.6.3 [\#1681](https://github.com/berkshelf/berkshelf/pull/1681) ([tduffield](https://github.com/tduffield))
- Specify appropriate proxies based on URI [\#1679](https://github.com/berkshelf/berkshelf/pull/1679) ([tduffield](https://github.com/tduffield))
- Remove spork [\#1672](https://github.com/berkshelf/berkshelf/pull/1672) ([biinari](https://github.com/biinari))

## [v5.6.2](https://github.com/berkshelf/berkshelf/tree/v5.6.2) (2017-02-05)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.1...v5.6.2)

**Merged pull requests:**

- fix for including hashie versions before the logger appeared [\#1675](https://github.com/berkshelf/berkshelf/pull/1675) ([lamont-granquist](https://github.com/lamont-granquist))

## [v5.6.1](https://github.com/berkshelf/berkshelf/tree/v5.6.1) (2017-02-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.6.0...v5.6.1)

**Merged pull requests:**

- Address hashie warning spam [\#1668](https://github.com/berkshelf/berkshelf/pull/1668) ([lamont-granquist](https://github.com/lamont-granquist))

## [v5.6.0](https://github.com/berkshelf/berkshelf/tree/v5.6.0) (2017-02-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.5.0...v5.6.0)

**Merged pull requests:**

- Bump Mixlib-Archive to 0.4 [\#1666](https://github.com/berkshelf/berkshelf/pull/1666) ([thommay](https://github.com/thommay))
- chefstyle fixes [\#1662](https://github.com/berkshelf/berkshelf/pull/1662) ([lamont-granquist](https://github.com/lamont-granquist))

## [v5.5.0](https://github.com/berkshelf/berkshelf/tree/v5.5.0) (2017-01-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.4.0...v5.5.0)

**Merged pull requests:**

- remove Thread.exclusive [\#1661](https://github.com/berkshelf/berkshelf/pull/1661) ([lamont-granquist](https://github.com/lamont-granquist))
- Revert vendoring metadata.rb file [\#1660](https://github.com/berkshelf/berkshelf/pull/1660) ([lamont-granquist](https://github.com/lamont-granquist))
- bundle update [\#1659](https://github.com/berkshelf/berkshelf/pull/1659) ([lamont-granquist](https://github.com/lamont-granquist))

## [v5.4.0](https://github.com/berkshelf/berkshelf/tree/v5.4.0) (2017-01-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.3.0...v5.4.0)

**Merged pull requests:**

- Prepare for 5.4.0 [\#1658](https://github.com/berkshelf/berkshelf/pull/1658) ([thommay](https://github.com/thommay))
- vendor the metadata.rb file [\#1652](https://github.com/berkshelf/berkshelf/pull/1652) ([lamont-granquist](https://github.com/lamont-granquist))
- Add a format option to berkz viz that outputs a dotfile [\#1646](https://github.com/berkshelf/berkshelf/pull/1646) ([borntyping](https://github.com/borntyping))

## [v5.3.0](https://github.com/berkshelf/berkshelf/tree/v5.3.0) (2016-12-15)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.2.0...v5.3.0)

**Merged pull requests:**

- Add SSLPolicy class that will use chefdk trusted certs path [\#1640](https://github.com/berkshelf/berkshelf/pull/1640) ([afiune](https://github.com/afiune))
- Add alternative way to run tests [\#1626](https://github.com/berkshelf/berkshelf/pull/1626) ([gliptak](https://github.com/gliptak))

## [v5.2.0](https://github.com/berkshelf/berkshelf/tree/v5.2.0) (2016-11-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.1.0...v5.2.0)

**Merged pull requests:**

- pin berkshelf-api, bump deps, remove failing matrix tests [\#1623](https://github.com/berkshelf/berkshelf/pull/1623) ([lamont-granquist](https://github.com/lamont-granquist))
- Community site error message missing URL [\#1621](https://github.com/berkshelf/berkshelf/pull/1621) ([tkling](https://github.com/tkling))
- Pass all ssl/X509 parameters to configuration [\#1600](https://github.com/berkshelf/berkshelf/pull/1600) ([thommay](https://github.com/thommay))

## [v5.1.0](https://github.com/berkshelf/berkshelf/tree/v5.1.0) (2016-09-16)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v5.0.0...v5.1.0)

**Merged pull requests:**

- Update version to 5.1.0 [\#1615](https://github.com/berkshelf/berkshelf/pull/1615) ([jkeiser](https://github.com/jkeiser))
- Disable caching of bundler since it's broken [\#1612](https://github.com/berkshelf/berkshelf/pull/1612) ([thommay](https://github.com/thommay))
- Update cli.rb [\#1611](https://github.com/berkshelf/berkshelf/pull/1611) ([martinmosegaard](https://github.com/martinmosegaard))
- fix cucumber tests [\#1609](https://github.com/berkshelf/berkshelf/pull/1609) ([mwrock](https://github.com/mwrock))
- Enable appveyor [\#1606](https://github.com/berkshelf/berkshelf/pull/1606) ([thommay](https://github.com/thommay))
- fix syncing windows user directories on ruby 2.3 [\#1605](https://github.com/berkshelf/berkshelf/pull/1605) ([mwrock](https://github.com/mwrock))
- Update buff-shell\_out to 1.0 [\#1604](https://github.com/berkshelf/berkshelf/pull/1604) ([jkeiser](https://github.com/jkeiser))
- Only fall back to cp/rm if we have to [\#1602](https://github.com/berkshelf/berkshelf/pull/1602) ([thommay](https://github.com/thommay))
- Expose configuration for API timeouts [\#1601](https://github.com/berkshelf/berkshelf/pull/1601) ([thommay](https://github.com/thommay))
- Only optionally remove the contents of the target [\#1599](https://github.com/berkshelf/berkshelf/pull/1599) ([thommay](https://github.com/thommay))

## [v5.0.0](https://github.com/berkshelf/berkshelf/tree/v5.0.0) (2016-08-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.5...v5.0.0)

**Merged pull requests:**

- Atomically move git located cookbook to cache [\#1598](https://github.com/berkshelf/berkshelf/pull/1598) ([kamaradclimber](https://github.com/kamaradclimber))
- Faild `berks install` with ENV\['BERKSHELF\_PATH'\] [\#1595](https://github.com/berkshelf/berkshelf/pull/1595) ([hirocaster](https://github.com/hirocaster))
- Add Ruby 2.3 and Ruby 2.4 support - drop Ruby 2.1 support and older [\#1591](https://github.com/berkshelf/berkshelf/pull/1591) ([lamont-granquist](https://github.com/lamont-granquist))
- bump berkshelf-api and associated deps [\#1589](https://github.com/berkshelf/berkshelf/pull/1589) ([lamont-granquist](https://github.com/lamont-granquist))
- force encoding to UTF-8 [\#1588](https://github.com/berkshelf/berkshelf/pull/1588) ([lamont-granquist](https://github.com/lamont-granquist))
- Bump dep-selector-libgecode to 1.3.1 [\#1586](https://github.com/berkshelf/berkshelf/pull/1586) ([stevendanna](https://github.com/stevendanna))
- allow user to change git url handler [\#1585](https://github.com/berkshelf/berkshelf/pull/1585) ([lamont-granquist](https://github.com/lamont-granquist))
- fix specs for bento box [\#1582](https://github.com/berkshelf/berkshelf/pull/1582) ([lamont-granquist](https://github.com/lamont-granquist))
- Fixes \#1473 where Lockfile\#trusted? would compare dependencies of oth… [\#1580](https://github.com/berkshelf/berkshelf/pull/1580) ([bbaugher](https://github.com/bbaugher))
- Require Ruby 2.1+ [\#1575](https://github.com/berkshelf/berkshelf/pull/1575) ([tas50](https://github.com/tas50))
- Add introductory docs for newcomers. [\#1520](https://github.com/berkshelf/berkshelf/pull/1520) ([jzohrab](https://github.com/jzohrab))
- Update Vagrantfile generator default vm box [\#1491](https://github.com/berkshelf/berkshelf/pull/1491) ([tannerj](https://github.com/tannerj))
- Add the support for "gitlab" location\_type passed by Berkshelf API  [\#1419](https://github.com/berkshelf/berkshelf/pull/1419) ([gueux](https://github.com/gueux))

## [v4.3.5](https://github.com/berkshelf/berkshelf/tree/v4.3.5) (2016-06-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.4...v4.3.5)

**Merged pull requests:**

- We released with a dependency on a github source [\#1572](https://github.com/berkshelf/berkshelf/pull/1572) ([tyler-ball](https://github.com/tyler-ball))
- Update docs to use `chef generate cookbook` instead of `berks init` or `berks cookbook`. [\#1568](https://github.com/berkshelf/berkshelf/pull/1568) ([tylercloke](https://github.com/tylercloke))

## [v4.3.4](https://github.com/berkshelf/berkshelf/tree/v4.3.4) (2016-06-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.3...v4.3.4)

**Merged pull requests:**

- Update release docs and bump Gemfile.lock. [\#1570](https://github.com/berkshelf/berkshelf/pull/1570) ([tylercloke](https://github.com/tylercloke))
- Release v4.3.4. [\#1569](https://github.com/berkshelf/berkshelf/pull/1569) ([tylercloke](https://github.com/tylercloke))
- Deprecate `berks init` in favor of `chef generate cookbook`. [\#1567](https://github.com/berkshelf/berkshelf/pull/1567) ([tylercloke](https://github.com/tylercloke))
- Deprecate `berks cookbook` in favor of `chef generate cookbook`. [\#1565](https://github.com/berkshelf/berkshelf/pull/1565) ([tylercloke](https://github.com/tylercloke))
- Use rubygem's tar implementation [\#1553](https://github.com/berkshelf/berkshelf/pull/1553) ([thommay](https://github.com/thommay))

## [v4.3.3](https://github.com/berkshelf/berkshelf/tree/v4.3.3) (2016-05-09)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.2...v4.3.3)

**Merged pull requests:**

- Fixing some specs that fail on Windows [\#1554](https://github.com/berkshelf/berkshelf/pull/1554) ([tyler-ball](https://github.com/tyler-ball))
- fix up @reset's review comments from \#1527 [\#1543](https://github.com/berkshelf/berkshelf/pull/1543) ([thommay](https://github.com/thommay))
- Correct usage of Net::HTTP.new [\#1532](https://github.com/berkshelf/berkshelf/pull/1532) ([xeron](https://github.com/xeron))

## [v4.3.2](https://github.com/berkshelf/berkshelf/tree/v4.3.2) (2016-04-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.1...v4.3.2)

**Merged pull requests:**

- Updating Test Kitchen to the latest version [\#1542](https://github.com/berkshelf/berkshelf/pull/1542) ([tyler-ball](https://github.com/tyler-ball))

## [v4.3.1](https://github.com/berkshelf/berkshelf/tree/v4.3.1) (2016-03-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.0...v4.3.1)

**Merged pull requests:**

- Update all dependencies [\#1535](https://github.com/berkshelf/berkshelf/pull/1535) ([danielsdeleo](https://github.com/danielsdeleo))

## [v4.3.0](https://github.com/berkshelf/berkshelf/tree/v4.3.0) (2016-03-09)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.3...v4.3.0)

**Merged pull requests:**

- update ridley in Gemfile.lock [\#1530](https://github.com/berkshelf/berkshelf/pull/1530) ([mwrock](https://github.com/mwrock))
- fix busted tests [\#1529](https://github.com/berkshelf/berkshelf/pull/1529) ([thommay](https://github.com/thommay))
- Support downloading universe from chef servers [\#1527](https://github.com/berkshelf/berkshelf/pull/1527) ([thommay](https://github.com/thommay))
- Unpin changelog generator to get rid of version conflicts [\#1525](https://github.com/berkshelf/berkshelf/pull/1525) ([jkeiser](https://github.com/jkeiser))

## [v4.2.3](https://github.com/berkshelf/berkshelf/tree/v4.2.3) (2016-02-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.2...v4.2.3)

**Merged pull requests:**

- Relax dependencies to accept minor version bumps [\#1523](https://github.com/berkshelf/berkshelf/pull/1523) ([jkeiser](https://github.com/jkeiser))

## [v4.2.2](https://github.com/berkshelf/berkshelf/tree/v4.2.2) (2016-02-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.1...v4.2.2)

**Merged pull requests:**

- Bump version to 4.2.2 [\#1522](https://github.com/berkshelf/berkshelf/pull/1522) ([jkeiser](https://github.com/jkeiser))
- Pin github\_changelog\_generator [\#1521](https://github.com/berkshelf/berkshelf/pull/1521) ([jkeiser](https://github.com/jkeiser))

## [v4.2.1](https://github.com/berkshelf/berkshelf/tree/v4.2.1) (2016-02-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.0...v4.2.1)

**Merged pull requests:**

- updating httpclient version dep to ~\> 2.7.0 [\#1518](https://github.com/berkshelf/berkshelf/pull/1518) ([someara](https://github.com/someara))

## [v4.2.0](https://github.com/berkshelf/berkshelf/tree/v4.2.0) (2016-02-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.1.1...v4.2.0)

**Merged pull requests:**

- Update the chef-config pin to 12.7.2 [\#1516](https://github.com/berkshelf/berkshelf/pull/1516) ([jaym](https://github.com/jaym))
- Apply locks to local json environment file [\#1512](https://github.com/berkshelf/berkshelf/pull/1512) ([louis-gounot](https://github.com/louis-gounot))

## [v4.1.1](https://github.com/berkshelf/berkshelf/tree/v4.1.1) (2016-02-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.1.0...v4.1.1)

**Merged pull requests:**

- Update solve to 2.0.2 [\#1509](https://github.com/berkshelf/berkshelf/pull/1509) ([danielsdeleo](https://github.com/danielsdeleo))
- Use github\_changelog\_generator [\#1507](https://github.com/berkshelf/berkshelf/pull/1507) ([jkeiser](https://github.com/jkeiser))

## [v4.1.0](https://github.com/berkshelf/berkshelf/tree/v4.1.0) (2016-02-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.0.1...v4.1.0)

**Merged pull requests:**

- remove berkshelf gem entry in generated Gemfile [\#1485](https://github.com/berkshelf/berkshelf/pull/1485) ([reset](https://github.com/reset))
- Pin aruba to 0.10.2 [\#1484](https://github.com/berkshelf/berkshelf/pull/1484) ([smith](https://github.com/smith))
- Add a new `solver` Berksfile DSL option [\#1482](https://github.com/berkshelf/berkshelf/pull/1482) ([martinb3](https://github.com/martinb3))
- Upgrade to solve 2.0 [\#1475](https://github.com/berkshelf/berkshelf/pull/1475) ([jkeiser](https://github.com/jkeiser))
- Use Net::HTTP.new instead of Net::HTTP.start [\#1467](https://github.com/berkshelf/berkshelf/pull/1467) ([jkeiser](https://github.com/jkeiser))
- Have berks install bump only required cookbooks [\#1462](https://github.com/berkshelf/berkshelf/pull/1462) ([FlorentFlament](https://github.com/FlorentFlament))

## [v4.0.1](https://github.com/berkshelf/berkshelf/tree/v4.0.1) (2015-10-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.0.0...v4.0.1)

## [v4.0.0](https://github.com/berkshelf/berkshelf/tree/v4.0.0) (2015-10-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.3.0...v4.0.0)

**Merged pull requests:**

- When doing 'berks install' Lock cookbooks' version according to the lockfile [\#1460](https://github.com/berkshelf/berkshelf/pull/1460) ([FlorentFlament](https://github.com/FlorentFlament))
- Removes the gzip middleware from Faraday builder. [\#1444](https://github.com/berkshelf/berkshelf/pull/1444) ([johnbellone](https://github.com/johnbellone))

## [v3.3.0](https://github.com/berkshelf/berkshelf/tree/v3.3.0) (2015-06-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.4...v3.3.0)

**Merged pull requests:**

- tiny docfixes [\#1434](https://github.com/berkshelf/berkshelf/pull/1434) ([dastergon](https://github.com/dastergon))
- Improved error msg for unknown compression types. [\#1433](https://github.com/berkshelf/berkshelf/pull/1433) ([patcon](https://github.com/patcon))
- Use httpclient instead of nethttp [\#1393](https://github.com/berkshelf/berkshelf/pull/1393) ([jf647](https://github.com/jf647))

## [v3.2.4](https://github.com/berkshelf/berkshelf/tree/v3.2.4) (2015-04-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.3...v3.2.4)

**Merged pull requests:**

- Fix defunct link. [\#1417](https://github.com/berkshelf/berkshelf/pull/1417) ([lorefnon](https://github.com/lorefnon))
- Fix link to chef repository article [\#1414](https://github.com/berkshelf/berkshelf/pull/1414) ([Maks3w](https://github.com/Maks3w))
- Chef-DK link has changed [\#1410](https://github.com/berkshelf/berkshelf/pull/1410) ([mreeves1](https://github.com/mreeves1))
- prevent race conditions [\#1398](https://github.com/berkshelf/berkshelf/pull/1398) ([shyouhei](https://github.com/shyouhei))
- SSL verify unrecognized by community\_rest.rb [\#1395](https://github.com/berkshelf/berkshelf/pull/1395) ([oldirty](https://github.com/oldirty))
- Use git: locations over github: in the Gemfile [\#1394](https://github.com/berkshelf/berkshelf/pull/1394) ([jf647](https://github.com/jf647))
- Adding '\*\*/.git' to exclusions. [\#1380](https://github.com/berkshelf/berkshelf/pull/1380) ([vinyar](https://github.com/vinyar))
- fix expected berkshelf-api-server version [\#1374](https://github.com/berkshelf/berkshelf/pull/1374) ([mwrock](https://github.com/mwrock))
- correctly return the max version from searches [\#1373](https://github.com/berkshelf/berkshelf/pull/1373) ([mwrock](https://github.com/mwrock))
- Fix small typos in index.md [\#1372](https://github.com/berkshelf/berkshelf/pull/1372) ([selesse](https://github.com/selesse))

## [v3.2.3](https://github.com/berkshelf/berkshelf/tree/v3.2.3) (2015-01-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.2...v3.2.3)

**Merged pull requests:**

- super minor typo fix [\#1367](https://github.com/berkshelf/berkshelf/pull/1367) ([dpetzel](https://github.com/dpetzel))
- Correct help command [\#1365](https://github.com/berkshelf/berkshelf/pull/1365) ([gsf](https://github.com/gsf))
- Fix e.message to show detailed error messages [\#1364](https://github.com/berkshelf/berkshelf/pull/1364) ([sonots](https://github.com/sonots))
- add ConfigurationError [\#1363](https://github.com/berkshelf/berkshelf/pull/1363) ([sonots](https://github.com/sonots))
- Fixed README description of config file search [\#1359](https://github.com/berkshelf/berkshelf/pull/1359) ([BackSlasher](https://github.com/BackSlasher))

## [v3.2.2](https://github.com/berkshelf/berkshelf/tree/v3.2.2) (2014-12-18)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.1...v3.2.2)

**Merged pull requests:**

- Only exclude top-level metadata.rb file while vendoring [\#1353](https://github.com/berkshelf/berkshelf/pull/1353) ([jpruetting](https://github.com/jpruetting))
- Use chef.io [\#1351](https://github.com/berkshelf/berkshelf/pull/1351) ([sethvargo](https://github.com/sethvargo))
- Use chef.io [\#1350](https://github.com/berkshelf/berkshelf/pull/1350) ([sethvargo](https://github.com/sethvargo))
- Fix edge cases with vendoring [\#1342](https://github.com/berkshelf/berkshelf/pull/1342) ([rchekaluk](https://github.com/rchekaluk))

## [v3.2.1](https://github.com/berkshelf/berkshelf/tree/v3.2.1) (2014-11-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.0...v3.2.1)

**Merged pull requests:**

- Correct exclusion of metadata.rb [\#1339](https://github.com/berkshelf/berkshelf/pull/1339) ([rveznaver](https://github.com/rveznaver))
- fix chefignore for files in sub directories [\#1335](https://github.com/berkshelf/berkshelf/pull/1335) ([thomas-riccardi](https://github.com/thomas-riccardi))
- Do not leak tempdirs [\#1334](https://github.com/berkshelf/berkshelf/pull/1334) ([sethvargo](https://github.com/sethvargo))

## [v3.2.0](https://github.com/berkshelf/berkshelf/tree/v3.2.0) (2014-10-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.5...v3.2.0)

**Merged pull requests:**

- Vagrant: Use vm.box\_url when vm.box is not a Vagrant Cloud box [\#1332](https://github.com/berkshelf/berkshelf/pull/1332) ([jossy](https://github.com/jossy))
- add 'verify' command to Berkshelf [\#1331](https://github.com/berkshelf/berkshelf/pull/1331) ([reset](https://github.com/reset))
- Use Vagrant.has\_plugin? for checking Omnibus [\#1330](https://github.com/berkshelf/berkshelf/pull/1330) ([sethvargo](https://github.com/sethvargo))
- Always expand the full path for BERKSFILE\_PATH [\#1329](https://github.com/berkshelf/berkshelf/pull/1329) ([sethvargo](https://github.com/sethvargo))
- Name the lockfile after the basename of the Berksfile [\#1328](https://github.com/berkshelf/berkshelf/pull/1328) ([sethvargo](https://github.com/sethvargo))
- Include the name of a cookbook when Ridley throws an error [\#1327](https://github.com/berkshelf/berkshelf/pull/1327) ([sethvargo](https://github.com/sethvargo))
- Do not delete the vendor directory [\#1326](https://github.com/berkshelf/berkshelf/pull/1326) ([sethvargo](https://github.com/sethvargo))
- Raised the celluloid version from pre to stable [\#1324](https://github.com/berkshelf/berkshelf/pull/1324) ([tboerger](https://github.com/tboerger))
- Adding a small if-else clause to change upload order [\#1316](https://github.com/berkshelf/berkshelf/pull/1316) ([svanharmelen](https://github.com/svanharmelen))
- Fixing \_PaxHeader\_ error on berks upload [\#1313](https://github.com/berkshelf/berkshelf/pull/1313) ([sbotman](https://github.com/sbotman))
- Fix Graphviz dependency checks on Windows [\#1312](https://github.com/berkshelf/berkshelf/pull/1312) ([glasschef](https://github.com/glasschef))
- Correct the gh-pages docs for the v2.0 `--without` cli arg as `--except` [\#1309](https://github.com/berkshelf/berkshelf/pull/1309) ([steve-jansen](https://github.com/steve-jansen))
- Fix linting issues [\#1301](https://github.com/berkshelf/berkshelf/pull/1301) ([chr4](https://github.com/chr4))
- Fix `berks viz` when `pwd` contains spaces [\#1294](https://github.com/berkshelf/berkshelf/pull/1294) ([ameir](https://github.com/ameir))
- Change 'berkshelf shelf uninstall' -\> 'berks shelf uninstall' [\#1293](https://github.com/berkshelf/berkshelf/pull/1293) ([ameir](https://github.com/ameir))
- Include the forgotten :graphviz tag in visualizer\_spec. [\#1291](https://github.com/berkshelf/berkshelf/pull/1291) ([sersut](https://github.com/sersut))
- Minor typo in cli.rb deprecation message. [\#1289](https://github.com/berkshelf/berkshelf/pull/1289) ([erichelgeson](https://github.com/erichelgeson))
- Add version information to edges of berks viz [\#1286](https://github.com/berkshelf/berkshelf/pull/1286) ([quodlibetor](https://github.com/quodlibetor))
- Fix failing specs and upgrade to RSpec 3 [\#1283](https://github.com/berkshelf/berkshelf/pull/1283) ([sethvargo](https://github.com/sethvargo))
- Use the cleanroom gem for evaluating DSLs [\#1282](https://github.com/berkshelf/berkshelf/pull/1282) ([sethvargo](https://github.com/sethvargo))
- Implement "downloading" for `file\_store` sources [\#991](https://github.com/berkshelf/berkshelf/pull/991) ([whiteley](https://github.com/whiteley))

## [v3.1.5](https://github.com/berkshelf/berkshelf/tree/v3.1.5) (2014-08-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.4...v3.1.5)

**Merged pull requests:**

- berks cookbook generator uninitialized constant Berkshelf::CookbookGenerator::LICENSES [\#1268](https://github.com/berkshelf/berkshelf/pull/1268) ([dasibre](https://github.com/dasibre))
- Add Super Market location\_type support [\#1238](https://github.com/berkshelf/berkshelf/pull/1238) ([reset](https://github.com/reset))

## [v3.1.4](https://github.com/berkshelf/berkshelf/tree/v3.1.4) (2014-07-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.18...v3.1.4)

**Merged pull requests:**

- Version bump v3.1.4 [\#1260](https://github.com/berkshelf/berkshelf/pull/1260) ([sethvargo](https://github.com/sethvargo))
- Replace api.berkshelf.com with supermarket.getchef.com [\#1259](https://github.com/berkshelf/berkshelf/pull/1259) ([Maks3w](https://github.com/Maks3w))
- Follow redirects when we try to get a cookbook [\#1258](https://github.com/berkshelf/berkshelf/pull/1258) ([jujugrrr](https://github.com/jujugrrr))
- update all api.berkshelf.com references to supermarket.getchef.com [\#1250](https://github.com/berkshelf/berkshelf/pull/1250) ([reset](https://github.com/reset))

## [v2.0.18](https://github.com/berkshelf/berkshelf/tree/v2.0.18) (2014-07-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.17...v2.0.18)

**Merged pull requests:**

- Follow redirects [\#1251](https://github.com/berkshelf/berkshelf/pull/1251) ([sethvargo](https://github.com/sethvargo))
- Updated default vagrant box to Ubuntu 14.04 from Vagrant Cloud [\#1217](https://github.com/berkshelf/berkshelf/pull/1217) ([jossy](https://github.com/jossy))

## [v2.0.17](https://github.com/berkshelf/berkshelf/tree/v2.0.17) (2014-06-10)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.3...v2.0.17)

**Merged pull requests:**

- Lockdown Hashie \(2.0\) [\#1231](https://github.com/berkshelf/berkshelf/pull/1231) ([sethvargo](https://github.com/sethvargo))

## [v3.1.3](https://github.com/berkshelf/berkshelf/tree/v3.1.3) (2014-06-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.2...v3.1.3)

**Merged pull requests:**

- bump ridley and buff dependencies [\#1219](https://github.com/berkshelf/berkshelf/pull/1219) ([reset](https://github.com/reset))
- Fixed a minor typo on the home page [\#1213](https://github.com/berkshelf/berkshelf/pull/1213) ([elektronaut](https://github.com/elektronaut))
- Extract git mixin into its own module [\#1209](https://github.com/berkshelf/berkshelf/pull/1209) ([sethvargo](https://github.com/sethvargo))
- ssl.verify option is ignored [\#1204](https://github.com/berkshelf/berkshelf/pull/1204) ([ohtake](https://github.com/ohtake))
- Fix windows specs [\#1200](https://github.com/berkshelf/berkshelf/pull/1200) ([danielsdeleo](https://github.com/danielsdeleo))
- Skip cached cookbooks missing their name attributes instead of failing [\#1198](https://github.com/berkshelf/berkshelf/pull/1198) ([KAllan357](https://github.com/KAllan357))

## [v3.1.2](https://github.com/berkshelf/berkshelf/tree/v3.1.2) (2014-05-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.16...v3.1.2)

**Merged pull requests:**

- Remove the .git directory for git-sourced cookbooks [\#1194](https://github.com/berkshelf/berkshelf/pull/1194) ([cnunciato](https://github.com/cnunciato))
- Apply environment file artifact [\#1188](https://github.com/berkshelf/berkshelf/pull/1188) ([stephenlauck](https://github.com/stephenlauck))
- Fix typo in show cmd description [\#1187](https://github.com/berkshelf/berkshelf/pull/1187) ([dougireton](https://github.com/dougireton))
- Do not care about ordered output during installation [\#1186](https://github.com/berkshelf/berkshelf/pull/1186) ([sethvargo](https://github.com/sethvargo))
- Update README.md.erb [\#1183](https://github.com/berkshelf/berkshelf/pull/1183) ([mjuszczak](https://github.com/mjuszczak))
- Fix Berkshelf::Graph\#update [\#1182](https://github.com/berkshelf/berkshelf/pull/1182) ([carkmorwin](https://github.com/carkmorwin))
- Update to buff-config ~\> 0.4 [\#1180](https://github.com/berkshelf/berkshelf/pull/1180) ([sethvargo](https://github.com/sethvargo))
- Fix infinite lock check [\#1178](https://github.com/berkshelf/berkshelf/pull/1178) ([mi-wood](https://github.com/mi-wood))
- Create a subclass of the shell instead of a module [\#1177](https://github.com/berkshelf/berkshelf/pull/1177) ([sethvargo](https://github.com/sethvargo))
- remove duplicate faraday dependency [\#1173](https://github.com/berkshelf/berkshelf/pull/1173) ([jamesc](https://github.com/jamesc))
- Handle when Celluloid.cores is nil [\#1169](https://github.com/berkshelf/berkshelf/pull/1169) ([douglaswth](https://github.com/douglaswth))
- Prefer https over http. [\#1168](https://github.com/berkshelf/berkshelf/pull/1168) ([arangamani](https://github.com/arangamani))
- add @graphviz tag to cucumber [\#1165](https://github.com/berkshelf/berkshelf/pull/1165) ([mcquin](https://github.com/mcquin))
- tag tests which require the presence of Graphviz so that they can be exc... [\#1163](https://github.com/berkshelf/berkshelf/pull/1163) ([mcquin](https://github.com/mcquin))
- Add bazaar plugin reference [\#1162](https://github.com/berkshelf/berkshelf/pull/1162) ([Da-Wei](https://github.com/Da-Wei))
- Update Thor API [\#1161](https://github.com/berkshelf/berkshelf/pull/1161) ([sethvargo](https://github.com/sethvargo))

## [v2.0.16](https://github.com/berkshelf/berkshelf/tree/v2.0.16) (2014-04-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.1...v2.0.16)

**Merged pull requests:**

- Berkshelf 2.0.15 won't install with Vagrant 1.5.3 [\#1146](https://github.com/berkshelf/berkshelf/pull/1146) ([gaffneyc](https://github.com/gaffneyc))

## [v3.1.1](https://github.com/berkshelf/berkshelf/tree/v3.1.1) (2014-04-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.0...v3.1.1)

**Merged pull requests:**

- Bump required Ridley version to 3.1 [\#1143](https://github.com/berkshelf/berkshelf/pull/1143) ([sethvargo](https://github.com/sethvargo))
- Fix outdated checks [\#1142](https://github.com/berkshelf/berkshelf/pull/1142) ([sethvargo](https://github.com/sethvargo))

## [v3.1.0](https://github.com/berkshelf/berkshelf/tree/v3.1.0) (2014-04-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.1...v3.1.0)

**Merged pull requests:**

- Add `berks viz` [\#1137](https://github.com/berkshelf/berkshelf/pull/1137) ([sethvargo](https://github.com/sethvargo))
- minimum viable depsolving exception handling fix [\#1136](https://github.com/berkshelf/berkshelf/pull/1136) ([lamont-granquist](https://github.com/lamont-granquist))
- Typo and edit to index page of docs [\#1133](https://github.com/berkshelf/berkshelf/pull/1133) ([nicgrayson](https://github.com/nicgrayson))
- Change `berks show` to output the path to a cookbook on disk [\#1053](https://github.com/berkshelf/berkshelf/pull/1053) ([sethvargo](https://github.com/sethvargo))

## [v3.0.1](https://github.com/berkshelf/berkshelf/tree/v3.0.1) (2014-04-15)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0...v3.0.1)

**Merged pull requests:**

- Celluloid worker pool requires at least 2 cores [\#1129](https://github.com/berkshelf/berkshelf/pull/1129) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0](https://github.com/berkshelf/berkshelf/tree/v3.0.0) (2014-04-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.15...v3.0.0)

**Merged pull requests:**

- use celluloid for threaded cookbook downloads [\#1127](https://github.com/berkshelf/berkshelf/pull/1127) ([reset](https://github.com/reset))

## [v2.0.15](https://github.com/berkshelf/berkshelf/tree/v2.0.15) (2014-04-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.rc1...v2.0.15)

**Merged pull requests:**

- `berks vendor` "cannot be trusted!" error [\#1124](https://github.com/berkshelf/berkshelf/pull/1124) ([JeanMertz](https://github.com/JeanMertz))
- Fix community cookbook download error  [\#1123](https://github.com/berkshelf/berkshelf/pull/1123) ([carkmorwin](https://github.com/carkmorwin))
- Remove gecode install instructions from README [\#1122](https://github.com/berkshelf/berkshelf/pull/1122) ([danielsdeleo](https://github.com/danielsdeleo))

## [v3.0.0.rc1](https://github.com/berkshelf/berkshelf/tree/v3.0.0.rc1) (2014-04-09)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta9...v3.0.0.rc1)

**Merged pull requests:**

- Force unlock elements in the graph when reducing [\#1117](https://github.com/berkshelf/berkshelf/pull/1117) ([sethvargo](https://github.com/sethvargo))
- Support transitive update [\#1115](https://github.com/berkshelf/berkshelf/pull/1115) ([sethvargo](https://github.com/sethvargo))
- Nope nope nope, nope, no. This is so fucking dangerous, no. [\#1114](https://github.com/berkshelf/berkshelf/pull/1114) ([reset](https://github.com/reset))
- Support uploading a single cookbook \(transitive dependency\) [\#1112](https://github.com/berkshelf/berkshelf/pull/1112) ([sethvargo](https://github.com/sethvargo))
- use system gecode when building [\#1111](https://github.com/berkshelf/berkshelf/pull/1111) ([reset](https://github.com/reset))
- Dump statuses in gitter [\#1110](https://github.com/berkshelf/berkshelf/pull/1110) ([sethvargo](https://github.com/sethvargo))
- Loosen constraint on Thor [\#1107](https://github.com/berkshelf/berkshelf/pull/1107) ([reset](https://github.com/reset))
- Add `--type` flag to `berks cookbook` command [\#955](https://github.com/berkshelf/berkshelf/pull/955) ([reset](https://github.com/reset))

## [v3.0.0.beta9](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta9) (2014-04-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta8...v3.0.0.beta9)

**Merged pull requests:**

- Update the API to use semverse [\#1106](https://github.com/berkshelf/berkshelf/pull/1106) ([sethvargo](https://github.com/sethvargo))
- BaseLOcation -\> BaseLocation [\#1105](https://github.com/berkshelf/berkshelf/pull/1105) ([EvanPurkhiser](https://github.com/EvanPurkhiser))
- Update API calls to Solve to match 1.0.0.dev [\#1104](https://github.com/berkshelf/berkshelf/pull/1104) ([reset](https://github.com/reset))
- update generator for Vagrant 1.5.x [\#1103](https://github.com/berkshelf/berkshelf/pull/1103) ([reset](https://github.com/reset))

## [v3.0.0.beta8](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta8) (2014-04-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta7...v3.0.0.beta8)

**Merged pull requests:**

- Update Ridley, Faraday, Berkshefl-API, Berkshefl-API-Client [\#1102](https://github.com/berkshelf/berkshelf/pull/1102) ([reset](https://github.com/reset))
- Berks package not producing tarballs compatible with chef-solo [\#1099](https://github.com/berkshelf/berkshelf/pull/1099) ([pghalliday](https://github.com/pghalliday))
- remove Berksfile and Berksfile.lock from generated chefignore file [\#1096](https://github.com/berkshelf/berkshelf/pull/1096) ([reset](https://github.com/reset))
- Add `berks search` command for searching remote sources [\#1092](https://github.com/berkshelf/berkshelf/pull/1092) ([sethvargo](https://github.com/sethvargo))
- Fix location delegation [\#1090](https://github.com/berkshelf/berkshelf/pull/1090) ([sethvargo](https://github.com/sethvargo))
- Add a feature for changing the location for a dependency [\#1089](https://github.com/berkshelf/berkshelf/pull/1089) ([sethvargo](https://github.com/sethvargo))
- Fix equality checking for PathLocations [\#1088](https://github.com/berkshelf/berkshelf/pull/1088) ([sethvargo](https://github.com/sethvargo))
- Add debug logging to the installer [\#1087](https://github.com/berkshelf/berkshelf/pull/1087) ([sethvargo](https://github.com/sethvargo))
- Fix Lockfile\#trusted? bugs [\#1086](https://github.com/berkshelf/berkshelf/pull/1086) ([sethvargo](https://github.com/sethvargo))
- Fix lockfile reduction algorithm \(and other things\) [\#1082](https://github.com/berkshelf/berkshelf/pull/1082) ([sethvargo](https://github.com/sethvargo))
- Fix git location caching [\#1078](https://github.com/berkshelf/berkshelf/pull/1078) ([sethvargo](https://github.com/sethvargo))
- Fix failing tests [\#1075](https://github.com/berkshelf/berkshelf/pull/1075) ([sethvargo](https://github.com/sethvargo))
- Add feature for updating a git location [\#1074](https://github.com/berkshelf/berkshelf/pull/1074) ([sethvargo](https://github.com/sethvargo))
- Updated README for PR \#1045 [\#1070](https://github.com/berkshelf/berkshelf/pull/1070) ([svanharmelen](https://github.com/svanharmelen))
- Add lifecycle command for bumping the local version [\#1065](https://github.com/berkshelf/berkshelf/pull/1065) ([sethvargo](https://github.com/sethvargo))
- Added location\_type :uri [\#1064](https://github.com/berkshelf/berkshelf/pull/1064) ([docwhat](https://github.com/docwhat))
- Suppress default location [\#1062](https://github.com/berkshelf/berkshelf/pull/1062) ([sethvargo](https://github.com/sethvargo))
- Recurse into transitive dependencies when lockfile trusting [\#1058](https://github.com/berkshelf/berkshelf/pull/1058) ([sethvargo](https://github.com/sethvargo))
- Make mercurial specs optional [\#1056](https://github.com/berkshelf/berkshelf/pull/1056) ([sersut](https://github.com/sersut))
- Improve errors [\#1051](https://github.com/berkshelf/berkshelf/pull/1051) ([sethvargo](https://github.com/sethvargo))
- Don't install when uploading [\#1049](https://github.com/berkshelf/berkshelf/pull/1049) ([sethvargo](https://github.com/sethvargo))
- Don't save the lockfile on reduction [\#1048](https://github.com/berkshelf/berkshelf/pull/1048) ([sethvargo](https://github.com/sethvargo))
- Added some logic so it can handle multiple Github configurations [\#1045](https://github.com/berkshelf/berkshelf/pull/1045) ([svanharmelen](https://github.com/svanharmelen))
- Warn us if git isn't found [\#1042](https://github.com/berkshelf/berkshelf/pull/1042) ([jjshoe](https://github.com/jjshoe))
- Treat branches, tags, refs, and revisions differently [\#1035](https://github.com/berkshelf/berkshelf/pull/1035) ([sethvargo](https://github.com/sethvargo))
- Use bundler's parallel downloader for installing [\#1033](https://github.com/berkshelf/berkshelf/pull/1033) ([sethvargo](https://github.com/sethvargo))
- Kernel.autoload Mixins [\#1031](https://github.com/berkshelf/berkshelf/pull/1031) ([sethvargo](https://github.com/sethvargo))
- Coerce Source\#uri to a string when checking if it is the default [\#1029](https://github.com/berkshelf/berkshelf/pull/1029) ([sethvargo](https://github.com/sethvargo))
- update README for oh-my-zsh plugin [\#1028](https://github.com/berkshelf/berkshelf/pull/1028) ([shengyou](https://github.com/shengyou))
- Add feature for vendoring transitive dependencies in path locations [\#1027](https://github.com/berkshelf/berkshelf/pull/1027) ([sethvargo](https://github.com/sethvargo))
- Make formatters object-oriented so we can Autoload them [\#1020](https://github.com/berkshelf/berkshelf/pull/1020) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta7](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta7) (2014-02-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta6...v3.0.0.beta7)

**Merged pull requests:**

- Add feature for vendoring transitive dependencies [\#1026](https://github.com/berkshelf/berkshelf/pull/1026) ([sethvargo](https://github.com/sethvargo))
- Update Vagrantfile.erb [\#1022](https://github.com/berkshelf/berkshelf/pull/1022) ([berniedurfee](https://github.com/berniedurfee))
- Don't load Octokit until we need it [\#1017](https://github.com/berkshelf/berkshelf/pull/1017) ([sethvargo](https://github.com/sethvargo))
- Refactor the lockfile to separate top-level dependencies from the graph [\#1009](https://github.com/berkshelf/berkshelf/pull/1009) ([sethvargo](https://github.com/sethvargo))
- Missing CHANGELOG.md [\#1007](https://github.com/berkshelf/berkshelf/pull/1007) ([jasnab](https://github.com/jasnab))
- berks vendor does not work if the path is nested [\#984](https://github.com/berkshelf/berkshelf/pull/984) ([rteabeault](https://github.com/rteabeault))
- Remove implicit default source [\#983](https://github.com/berkshelf/berkshelf/pull/983) ([borntyping](https://github.com/borntyping))
- Raise on all commands when install is required but not performed [\#949](https://github.com/berkshelf/berkshelf/pull/949) ([reset](https://github.com/reset))

## [v3.0.0.beta6](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta6) (2014-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.14...v3.0.0.beta6)

## [v2.0.14](https://github.com/berkshelf/berkshelf/tree/v2.0.14) (2014-02-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta5...v2.0.14)

**Merged pull requests:**

- Update berksfile.rb [\#1006](https://github.com/berkshelf/berkshelf/pull/1006) ([erichelgeson](https://github.com/erichelgeson))
- Backport metadata.json detection logic to berks2 [\#1004](https://github.com/berkshelf/berkshelf/pull/1004) ([ivey](https://github.com/ivey))
- Sane defaults for OSX and keep current dir [\#1000](https://github.com/berkshelf/berkshelf/pull/1000) ([mjallday](https://github.com/mjallday))
- Issue 978 - Make sure to add dependencies to artifacts that are loaded from the cookbook store [\#997](https://github.com/berkshelf/berkshelf/pull/997) ([rteabeault](https://github.com/rteabeault))

## [v3.0.0.beta5](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta5) (2014-01-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.13...v3.0.0.beta5)

## [v2.0.13](https://github.com/berkshelf/berkshelf/tree/v2.0.13) (2014-01-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.12...v2.0.13)

**Merged pull requests:**

- Fix extra whitespace when commented line is empty [\#989](https://github.com/berkshelf/berkshelf/pull/989) ([cpuguy83](https://github.com/cpuguy83))
- enable downloading from private github repos [\#982](https://github.com/berkshelf/berkshelf/pull/982) ([punkle](https://github.com/punkle))

## [v2.0.12](https://github.com/berkshelf/berkshelf/tree/v2.0.12) (2014-01-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.11...v2.0.12)

## [v2.0.11](https://github.com/berkshelf/berkshelf/tree/v2.0.11) (2014-01-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta4...v2.0.11)

**Merged pull requests:**

- Make sure path/scm location is used during dependency resolution [\#976](https://github.com/berkshelf/berkshelf/pull/976) ([grobie](https://github.com/grobie))
- Fix typo [\#974](https://github.com/berkshelf/berkshelf/pull/974) ([gregkare](https://github.com/gregkare))
- improve warnings when receiving APIClientErrors when building universe [\#971](https://github.com/berkshelf/berkshelf/pull/971) ([reset](https://github.com/reset))
- Berkshelf 3 overrides custom cookbooks w/ "locked\_version" of community cookbooks. [\#963](https://github.com/berkshelf/berkshelf/pull/963) ([joestump](https://github.com/joestump))
- Added a Berkshelf 3 notice to the homepage. [\#962](https://github.com/berkshelf/berkshelf/pull/962) ([joestump](https://github.com/joestump))
- Added a warning about Berkshelf 2 being unsupported and a link to how to install 3. [\#960](https://github.com/berkshelf/berkshelf/pull/960) ([joestump](https://github.com/joestump))
- Add deprecation warning for `berks install --path` [\#954](https://github.com/berkshelf/berkshelf/pull/954) ([reset](https://github.com/reset))
- more robust checking for bash completion [\#951](https://github.com/berkshelf/berkshelf/pull/951) ([invsblduck](https://github.com/invsblduck))
- properly handle error codes other than 200 from api server [\#948](https://github.com/berkshelf/berkshelf/pull/948) ([reset](https://github.com/reset))
- add a github downloader [\#947](https://github.com/berkshelf/berkshelf/pull/947) ([punkle](https://github.com/punkle))
- Make Berkshelf API Client it's own gem [\#945](https://github.com/berkshelf/berkshelf/pull/945) ([sethvargo](https://github.com/sethvargo))
- add open timeout and timeout settings to API client [\#944](https://github.com/berkshelf/berkshelf/pull/944) ([reset](https://github.com/reset))
- add \#warn function to formatters [\#943](https://github.com/berkshelf/berkshelf/pull/943) ([reset](https://github.com/reset))
- Greatly improve `berks package` command [\#942](https://github.com/berkshelf/berkshelf/pull/942) ([reset](https://github.com/reset))
- properly identify a cookbook on disk by it's metadata [\#941](https://github.com/berkshelf/berkshelf/pull/941) ([reset](https://github.com/reset))
- Make 'package' command to filter hidden files from chefignore [\#940](https://github.com/berkshelf/berkshelf/pull/940) ([noorul](https://github.com/noorul))
- berksfile.lock not honored for transitive dependencies [\#939](https://github.com/berkshelf/berkshelf/pull/939) ([kashook](https://github.com/kashook))
- Looking for wrong version [\#907](https://github.com/berkshelf/berkshelf/pull/907) ([scalp42](https://github.com/scalp42))
- exception info swallowed when git protocol doesn't work [\#879](https://github.com/berkshelf/berkshelf/pull/879) ([cjerdonek](https://github.com/cjerdonek))
- `berks install --quiet` mutes error output [\#827](https://github.com/berkshelf/berkshelf/pull/827) ([torandu](https://github.com/torandu))

## [v3.0.0.beta4](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta4) (2013-12-05)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta3...v3.0.0.beta4)

**Merged pull requests:**

- Ensure Berksfile.lock goes along with vendored cookbooks [\#935](https://github.com/berkshelf/berkshelf/pull/935) ([reset](https://github.com/reset))
- locked\_version must be present for all items in Lockfile [\#934](https://github.com/berkshelf/berkshelf/pull/934) ([reset](https://github.com/reset))
- berks apply is an action on a lockfile, not a berksfile [\#933](https://github.com/berkshelf/berkshelf/pull/933) ([reset](https://github.com/reset))
- Fix for tests on Windows [\#926](https://github.com/berkshelf/berkshelf/pull/926) ([rarenerd](https://github.com/rarenerd))
- generate instructions for using edge berkshelf + vagrant-berkshelf [\#925](https://github.com/berkshelf/berkshelf/pull/925) ([reset](https://github.com/reset))
- metadata.rb should be compiled into metadata.json before vendoring [\#923](https://github.com/berkshelf/berkshelf/pull/923) ([reset](https://github.com/reset))
- Address issue \#921: clarify configuration documentation [\#922](https://github.com/berkshelf/berkshelf/pull/922) ([cjerdonek](https://github.com/cjerdonek))
- Fix handling chefignore [\#917](https://github.com/berkshelf/berkshelf/pull/917) ([chulkilee](https://github.com/chulkilee))
- improvements to generated README [\#915](https://github.com/berkshelf/berkshelf/pull/915) ([reset](https://github.com/reset))
- Update org locs [\#909](https://github.com/berkshelf/berkshelf/pull/909) ([reset](https://github.com/reset))
- Removed Outdated Vagrant configuration [\#905](https://github.com/berkshelf/berkshelf/pull/905) ([gosuri](https://github.com/gosuri))
- Remove the `berks configure` command [\#903](https://github.com/berkshelf/berkshelf/pull/903) ([sethvargo](https://github.com/sethvargo))
- Rebase and rename branch of pull request \#871 [\#881](https://github.com/berkshelf/berkshelf/pull/881) ([cjerdonek](https://github.com/cjerdonek))
- Address issue \#845: Raise a helpful error if github location ends in .git [\#874](https://github.com/berkshelf/berkshelf/pull/874) ([cjerdonek](https://github.com/cjerdonek))
- Workaround issue where Cygwin Git will create a directory called C: in [\#872](https://github.com/berkshelf/berkshelf/pull/872) ([douglaswth](https://github.com/douglaswth))
- Equality pinning forward port [\#870](https://github.com/berkshelf/berkshelf/pull/870) ([capoferro](https://github.com/capoferro))
- improve git location display for issue \#867 [\#869](https://github.com/berkshelf/berkshelf/pull/869) ([cjerdonek](https://github.com/cjerdonek))
- Add skip\_syntax\_check feature again [\#866](https://github.com/berkshelf/berkshelf/pull/866) ([josacar](https://github.com/josacar))
- Berkshelf 3 Fixes - Logging and Output [\#865](https://github.com/berkshelf/berkshelf/pull/865) ([KAllan357](https://github.com/KAllan357))
- 'berks list' does an implicit 'install' [\#833](https://github.com/berkshelf/berkshelf/pull/833) ([jeffkimble](https://github.com/jeffkimble))

## [v3.0.0.beta3](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta3) (2013-10-17)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.10...v3.0.0.beta3)

**Merged pull requests:**

- Fix bersk\* typos [\#863](https://github.com/berkshelf/berkshelf/pull/863) ([justincampbell](https://github.com/justincampbell))
- \[README.md\] fixed numbered-list formatting error in Contributing section [\#850](https://github.com/berkshelf/berkshelf/pull/850) ([caryp](https://github.com/caryp))
- Updated README.md template to match the latest version in knife [\#848](https://github.com/berkshelf/berkshelf/pull/848) ([caryp](https://github.com/caryp))
- Reduce the number of remote API calls in setup steps and refactor cucumber tests [\#844](https://github.com/berkshelf/berkshelf/pull/844) ([sethvargo](https://github.com/sethvargo))
- Avoid reloading each cached cookbook on every resolve [\#842](https://github.com/berkshelf/berkshelf/pull/842) ([sethvargo](https://github.com/sethvargo))
- If there is a locked\_version, check the CookbookStore directly [\#841](https://github.com/berkshelf/berkshelf/pull/841) ([sethvargo](https://github.com/sethvargo))
- bump celluloid/ridley dependencies [\#840](https://github.com/berkshelf/berkshelf/pull/840) ([reset](https://github.com/reset))
- Equality pinning 2 0 [\#838](https://github.com/berkshelf/berkshelf/pull/838) ([sethvargo](https://github.com/sethvargo))
- use HTTPS instead of HTTP for api.berkshelf.com [\#837](https://github.com/berkshelf/berkshelf/pull/837) ([reset](https://github.com/reset))
- Standardize cucumber tests [\#776](https://github.com/berkshelf/berkshelf/pull/776) ([sethvargo](https://github.com/sethvargo))

## [v2.0.10](https://github.com/berkshelf/berkshelf/tree/v2.0.10) (2013-09-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.9...v2.0.10)

**Merged pull requests:**

- Avoid reloading each cached cookbook on every resolve [\#829](https://github.com/berkshelf/berkshelf/pull/829) ([kainosnoema](https://github.com/kainosnoema))
- Accept an environment variable to debug solve [\#824](https://github.com/berkshelf/berkshelf/pull/824) ([sethvargo](https://github.com/sethvargo))
- `berks init` should raise a friendly error if the current directory does not contain a cookbook [\#821](https://github.com/berkshelf/berkshelf/pull/821) ([reset](https://github.com/reset))
- Allow chef client name and key to be overridden for cookbook uploads [\#818](https://github.com/berkshelf/berkshelf/pull/818) ([kashook](https://github.com/kashook))
- Allow chef client name and key to be overridden for cookbook uploads [\#817](https://github.com/berkshelf/berkshelf/pull/817) ([kashook](https://github.com/kashook))
- generate new Vagrantfile's with 1.9 style hashes [\#813](https://github.com/berkshelf/berkshelf/pull/813) ([reset](https://github.com/reset))

## [v2.0.9](https://github.com/berkshelf/berkshelf/tree/v2.0.9) (2013-08-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.8...v2.0.9)

**Merged pull requests:**

- Bump ridley [\#812](https://github.com/berkshelf/berkshelf/pull/812) ([reset](https://github.com/reset))
- Dependencies with a path location take precedence over locked ones [\#809](https://github.com/berkshelf/berkshelf/pull/809) ([reset](https://github.com/reset))
- Support -h and --help flags on subcommands [\#806](https://github.com/berkshelf/berkshelf/pull/806) ([sethvargo](https://github.com/sethvargo))
- Enable use of vagrant-omnibus plugin in generated vagrant files [\#799](https://github.com/berkshelf/berkshelf/pull/799) ([pghalliday](https://github.com/pghalliday))
- Fixed bash-completion directory path [\#797](https://github.com/berkshelf/berkshelf/pull/797) ([chrisyunker](https://github.com/chrisyunker))
- Use HTTPS by default for community API [\#775](https://github.com/berkshelf/berkshelf/pull/775) ([coderanger](https://github.com/coderanger))
- Fix issue where location is nil for cookbook that is in the cache [\#772](https://github.com/berkshelf/berkshelf/pull/772) ([b-dean](https://github.com/b-dean))
- Refactor ChefIgnore [\#748](https://github.com/berkshelf/berkshelf/pull/748) ([sethvargo](https://github.com/sethvargo))

## [v2.0.8](https://github.com/berkshelf/berkshelf/tree/v2.0.8) (2013-08-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta2...v2.0.8)

**Merged pull requests:**

- relax constraint on ridley to ~\> 1.5 [\#786](https://github.com/berkshelf/berkshelf/pull/786) ([reset](https://github.com/reset))
- bump required solve version \>= 0.8.0 [\#783](https://github.com/berkshelf/berkshelf/pull/783) ([reset](https://github.com/reset))
- Missing backtick on incompatible version error [\#782](https://github.com/berkshelf/berkshelf/pull/782) ([ocxo](https://github.com/ocxo))
- From bug https://github.com/RiotGames/berkshelf/issues/758 [\#778](https://github.com/berkshelf/berkshelf/pull/778) ([riotcku](https://github.com/riotcku))
- clean hard tabs [\#771](https://github.com/berkshelf/berkshelf/pull/771) ([j4y](https://github.com/j4y))
- When Cucumber can’t find a matching Step Definition [\#768](https://github.com/berkshelf/berkshelf/pull/768) ([sethvargo](https://github.com/sethvargo))
- @tknerr metadata deps not honored [\#717](https://github.com/berkshelf/berkshelf/pull/717) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta2](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta2) (2013-07-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta1...v3.0.0.beta2)

**Merged pull requests:**

- skip uploading an already uploaded metadata dependency [\#769](https://github.com/berkshelf/berkshelf/pull/769) ([reset](https://github.com/reset))
- Fix skipped outdated formatter [\#767](https://github.com/berkshelf/berkshelf/pull/767) ([sethvargo](https://github.com/sethvargo))
- Berksfile.lock overwritten? [\#765](https://github.com/berkshelf/berkshelf/pull/765) ([sfiggins](https://github.com/sfiggins))
- Fix a lost commit [\#763](https://github.com/berkshelf/berkshelf/pull/763) ([sethvargo](https://github.com/sethvargo))
- change default vendor location to 'berks-cookbooks' [\#757](https://github.com/berkshelf/berkshelf/pull/757) ([reset](https://github.com/reset))
- Don't install cookbooks when looking for outdated ones [\#755](https://github.com/berkshelf/berkshelf/pull/755) ([sethvargo](https://github.com/sethvargo))
- Only show failing specs and cukes on Travis [\#753](https://github.com/berkshelf/berkshelf/pull/753) ([sethvargo](https://github.com/sethvargo))
- Listen to the lockfile [\#752](https://github.com/berkshelf/berkshelf/pull/752) ([sethvargo](https://github.com/sethvargo))
- `Berks package` should packaging properly for chef-solo  [\#749](https://github.com/berkshelf/berkshelf/pull/749) ([johntdyer](https://github.com/johntdyer))
- Mercurial Support \(rebased\) [\#746](https://github.com/berkshelf/berkshelf/pull/746) ([mryan43](https://github.com/mryan43))
- Remove unused fixtures [\#744](https://github.com/berkshelf/berkshelf/pull/744) ([sethvargo](https://github.com/sethvargo))
- Fix RSpec deprecation error [\#742](https://github.com/berkshelf/berkshelf/pull/742) ([sethvargo](https://github.com/sethvargo))
- Use Ridley::Chef::Config [\#741](https://github.com/berkshelf/berkshelf/pull/741) ([sethvargo](https://github.com/sethvargo))
- `berks show` should not install cookbooks for the end user [\#740](https://github.com/berkshelf/berkshelf/pull/740) ([reset](https://github.com/reset))
- Rescue all errors, include Errno::EDENT [\#736](https://github.com/berkshelf/berkshelf/pull/736) ([sethvargo](https://github.com/sethvargo))
- Rescue all errors when evaluating the Berksfile [\#735](https://github.com/berkshelf/berkshelf/pull/735) ([sethvargo](https://github.com/sethvargo))
- Just output the version string instead of License and Authors as well [\#733](https://github.com/berkshelf/berkshelf/pull/733) ([sethvargo](https://github.com/sethvargo))
- Properly implement `berks outdated` [\#731](https://github.com/berkshelf/berkshelf/pull/731) ([reset](https://github.com/reset))
- `berks vendor` command to replace `berks install --path` [\#729](https://github.com/berkshelf/berkshelf/pull/729) ([reset](https://github.com/reset))
- Always raise exception when uploading a metadata frozen cookbook [\#692](https://github.com/berkshelf/berkshelf/pull/692) ([sethvargo](https://github.com/sethvargo))
- Fix lockfile speed issues \(master\) [\#684](https://github.com/berkshelf/berkshelf/pull/684) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta1](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta1) (2013-07-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.7...v3.0.0.beta1)

**Merged pull requests:**

- Use the Berkshelf API Server in the resolver [\#693](https://github.com/berkshelf/berkshelf/pull/693) ([reset](https://github.com/reset))

## [v2.0.7](https://github.com/berkshelf/berkshelf/tree/v2.0.7) (2013-07-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.6...v2.0.7)

**Merged pull requests:**

- Fix generator files to allow multiple hyphens in cookbook\_name [\#732](https://github.com/berkshelf/berkshelf/pull/732) ([maoe](https://github.com/maoe))
- Lockfile load 2 0 stable [\#728](https://github.com/berkshelf/berkshelf/pull/728) ([sethvargo](https://github.com/sethvargo))
- Rescue CookbookNotFound in lockfile\#load! [\#727](https://github.com/berkshelf/berkshelf/pull/727) ([sethvargo](https://github.com/sethvargo))
- Fixing issue with relative cookbook paths while processing a Berksfile \(Issue 721\) [\#723](https://github.com/berkshelf/berkshelf/pull/723) ([krmichelos](https://github.com/krmichelos))
- Fixing issue with relative cookbook paths while processing a Berksfile \(Issue 721\) [\#722](https://github.com/berkshelf/berkshelf/pull/722) ([krmichelos](https://github.com/krmichelos))
- Fixed 'greater than equal to' symbol in index.md [\#720](https://github.com/berkshelf/berkshelf/pull/720) ([kppullin](https://github.com/kppullin))

## [v2.0.6](https://github.com/berkshelf/berkshelf/tree/v2.0.6) (2013-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.5...v2.0.6)

**Merged pull requests:**

- clarify usage of branch, tag and ref keys [\#719](https://github.com/berkshelf/berkshelf/pull/719) ([josephholsten](https://github.com/josephholsten))
- Add test for Unicode characters [\#716](https://github.com/berkshelf/berkshelf/pull/716) ([sethvargo](https://github.com/sethvargo))
- Add test for Unicode characters [\#715](https://github.com/berkshelf/berkshelf/pull/715) ([sethvargo](https://github.com/sethvargo))
- Backport dependencies fixes [\#711](https://github.com/berkshelf/berkshelf/pull/711) ([sethvargo](https://github.com/sethvargo))
- ActiveSupport 4.0 breaks everything [\#710](https://github.com/berkshelf/berkshelf/pull/710) ([coderanger](https://github.com/coderanger))
- Move back to a single builder [\#698](https://github.com/berkshelf/berkshelf/pull/698) ([sethvargo](https://github.com/sethvargo))
- Remove support for Ruby 1.9.2 [\#697](https://github.com/berkshelf/berkshelf/pull/697) ([sethvargo](https://github.com/sethvargo))
- always resolve dependencies [\#694](https://github.com/berkshelf/berkshelf/pull/694) ([thommay](https://github.com/thommay))
- Speed up aruba [\#504](https://github.com/berkshelf/berkshelf/pull/504) ([sethvargo](https://github.com/sethvargo))

## [v2.0.5](https://github.com/berkshelf/berkshelf/tree/v2.0.5) (2013-06-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.4...v2.0.5)

**Merged pull requests:**

- Gracefully fail LockfileParserError and handle empty lockfiles [\#687](https://github.com/berkshelf/berkshelf/pull/687) ([sethvargo](https://github.com/sethvargo))
- If a Berksfile.lock is empty, berks stacktraces trying to read it [\#686](https://github.com/berkshelf/berkshelf/pull/686) ([capoferro](https://github.com/capoferro))
- Fix lockfile speed issues \(2-0-stable\) [\#683](https://github.com/berkshelf/berkshelf/pull/683) ([sethvargo](https://github.com/sethvargo))
- Forwardport lockfile fixes [\#681](https://github.com/berkshelf/berkshelf/pull/681) ([sethvargo](https://github.com/sethvargo))
- remove dependency on active support [\#678](https://github.com/berkshelf/berkshelf/pull/678) ([reset](https://github.com/reset))
- run unit and acceptance tests at the same time [\#677](https://github.com/berkshelf/berkshelf/pull/677) ([reset](https://github.com/reset))
- handle gzipped responses from the community site [\#675](https://github.com/berkshelf/berkshelf/pull/675) ([reset](https://github.com/reset))
- replace Chozo::Config with Buff::Config [\#673](https://github.com/berkshelf/berkshelf/pull/673) ([reset](https://github.com/reset))

## [v2.0.4](https://github.com/berkshelf/berkshelf/tree/v2.0.4) (2013-06-17)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.6...v2.0.4)

**Merged pull requests:**

- Rename lockfile sources to dependencies [\#665](https://github.com/berkshelf/berkshelf/pull/665) ([sethvargo](https://github.com/sethvargo))
- Read error message master \(3.0\) [\#663](https://github.com/berkshelf/berkshelf/pull/663) ([sethvargo](https://github.com/sethvargo))
- Read error message in BerksfileReadError \(2.0\) [\#662](https://github.com/berkshelf/berkshelf/pull/662) ([sethvargo](https://github.com/sethvargo))
- Remove explicit TK Dependency [\#659](https://github.com/berkshelf/berkshelf/pull/659) ([reset](https://github.com/reset))
- Use .values instead of mapping the hash \(3.0\) [\#653](https://github.com/berkshelf/berkshelf/pull/653) ([sethvargo](https://github.com/sethvargo))
- Use .values instead of mapping the hash \(2.0\) [\#652](https://github.com/berkshelf/berkshelf/pull/652) ([sethvargo](https://github.com/sethvargo))
- Remove a test that creeped in from master [\#651](https://github.com/berkshelf/berkshelf/pull/651) ([sethvargo](https://github.com/sethvargo))
- Fix broken metadata constraints [\#648](https://github.com/berkshelf/berkshelf/pull/648) ([sethvargo](https://github.com/sethvargo))
- Regression in speed improvements when installing with a Berksfile.lock [\#646](https://github.com/berkshelf/berkshelf/pull/646) ([reset](https://github.com/reset))
- rename cookbook source/sources to dependency/dependencies [\#640](https://github.com/berkshelf/berkshelf/pull/640) ([reset](https://github.com/reset))
- File syntax check [\#632](https://github.com/berkshelf/berkshelf/pull/632) ([sethvargo](https://github.com/sethvargo))
- `berks install` should not write a locked version for a cookbook installed by `metadata` [\#623](https://github.com/berkshelf/berkshelf/pull/623) ([reset](https://github.com/reset))

## [v1.4.6](https://github.com/berkshelf/berkshelf/tree/v1.4.6) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.3...v1.4.6)

**Merged pull requests:**

- Merge pull request \#629 from RiotGames/rel\_lockfile [\#644](https://github.com/berkshelf/berkshelf/pull/644) ([reset](https://github.com/reset))
- Merge pull request \#642 from RiotGames/use-mixin-shellout [\#643](https://github.com/berkshelf/berkshelf/pull/643) ([reset](https://github.com/reset))
- use Mixin::ShellOut instead of Ridley::Mixin::ShellOut [\#642](https://github.com/berkshelf/berkshelf/pull/642) ([reset](https://github.com/reset))
- Add bzip2 tarball support [\#641](https://github.com/berkshelf/berkshelf/pull/641) ([pdf](https://github.com/pdf))
- cached relative path of git repo broken in 2.0.1 [\#629](https://github.com/berkshelf/berkshelf/pull/629) ([bhouse](https://github.com/bhouse))
- Fix metadata nested constraints [\#626](https://github.com/berkshelf/berkshelf/pull/626) ([sethvargo](https://github.com/sethvargo))
- Full backport default locations [\#598](https://github.com/berkshelf/berkshelf/pull/598) ([sethvargo](https://github.com/sethvargo))

## [v2.0.3](https://github.com/berkshelf/berkshelf/tree/v2.0.3) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.2...v2.0.3)

**Merged pull requests:**

- pass blocks to methods exposed by Mixin::DSLEval [\#638](https://github.com/berkshelf/berkshelf/pull/638) ([reset](https://github.com/reset))

## [v2.0.2](https://github.com/berkshelf/berkshelf/tree/v2.0.2) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.1...v2.0.2)

**Merged pull requests:**

- use Ridley's ShellOut to fix issues with thread saftey and windows [\#636](https://github.com/berkshelf/berkshelf/pull/636) ([reset](https://github.com/reset))
- move thor/monkies to thor\_ext [\#635](https://github.com/berkshelf/berkshelf/pull/635) ([reset](https://github.com/reset))
- only expose methods we want to the Berksfile DSL [\#634](https://github.com/berkshelf/berkshelf/pull/634) ([reset](https://github.com/reset))
- berks upload --skip-dependencies goes down in flames [\#631](https://github.com/berkshelf/berkshelf/pull/631) ([thommay](https://github.com/thommay))
- Unknown license error when running `berks cookbook` [\#624](https://github.com/berkshelf/berkshelf/pull/624) ([dougireton](https://github.com/dougireton))

## [v2.0.1](https://github.com/berkshelf/berkshelf/tree/v2.0.1) (2013-06-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.0...v2.0.1)

**Merged pull requests:**

- CLI does not actually respect the `-c` flag [\#622](https://github.com/berkshelf/berkshelf/pull/622) ([reset](https://github.com/reset))
- Debug/Verbose logging is broken [\#621](https://github.com/berkshelf/berkshelf/pull/621) ([reset](https://github.com/reset))
- Berksfile will now be installed instead of resolved before upload [\#620](https://github.com/berkshelf/berkshelf/pull/620) ([reset](https://github.com/reset))
- Bump .ruby-version to 1.9.3-p429 \[ci skip\] [\#619](https://github.com/berkshelf/berkshelf/pull/619) ([sethvargo](https://github.com/sethvargo))
- Fixing the version location in outdated source error message [\#618](https://github.com/berkshelf/berkshelf/pull/618) ([jeremyolliver](https://github.com/jeremyolliver))

## [v2.0.0](https://github.com/berkshelf/berkshelf/tree/v2.0.0) (2013-06-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.5...v2.0.0)

**Merged pull requests:**

- test command registered to the CLI properly [\#610](https://github.com/berkshelf/berkshelf/pull/610) ([reset](https://github.com/reset))
- remove all @author tags from source - rely on gemspec/readme/license [\#609](https://github.com/berkshelf/berkshelf/pull/609) ([reset](https://github.com/reset))
- add Seth Vargo to authors list [\#608](https://github.com/berkshelf/berkshelf/pull/608) ([reset](https://github.com/reset))
- Berks cookbook misplaces files [\#603](https://github.com/berkshelf/berkshelf/pull/603) ([sethvargo](https://github.com/sethvargo))
- remove quotes around `ref` as they will break `:git` locations \(at least... [\#602](https://github.com/berkshelf/berkshelf/pull/602) ([tknerr](https://github.com/tknerr))
- Turns out the default sites were actually broken... [\#599](https://github.com/berkshelf/berkshelf/pull/599) ([sethvargo](https://github.com/sethvargo))
- Don't generate real keys [\#596](https://github.com/berkshelf/berkshelf/pull/596) ([sethvargo](https://github.com/sethvargo))
- Take \#2 at replacing MixLib::Shellout [\#593](https://github.com/berkshelf/berkshelf/pull/593) ([sethvargo](https://github.com/sethvargo))
- Chef Zero still broken [\#592](https://github.com/berkshelf/berkshelf/pull/592) ([sethvargo](https://github.com/sethvargo))
- Bring berkshelf specs up to the latest chef-zero [\#589](https://github.com/berkshelf/berkshelf/pull/589) ([jkeiser](https://github.com/jkeiser))
- `berks shelf show` should take an optional VERSION argument [\#586](https://github.com/berkshelf/berkshelf/pull/586) ([reset](https://github.com/reset))
- :json is not registered on Faraday::Response \(RuntimeError\) [\#581](https://github.com/berkshelf/berkshelf/pull/581) ([mconigliaro](https://github.com/mconigliaro))
- Create `berks shelf` [\#579](https://github.com/berkshelf/berkshelf/pull/579) ([sethvargo](https://github.com/sethvargo))
- Convert many things to single quotes [\#575](https://github.com/berkshelf/berkshelf/pull/575) ([sethvargo](https://github.com/sethvargo))
- Remove mixlib-config as a dependency [\#571](https://github.com/berkshelf/berkshelf/pull/571) ([sethvargo](https://github.com/sethvargo))
- Speed up \#show command and operate off a Berksfile [\#564](https://github.com/berkshelf/berkshelf/pull/564) ([sethvargo](https://github.com/sethvargo))
- Require a Berksfile for the \#info command [\#563](https://github.com/berkshelf/berkshelf/pull/563) ([sethvargo](https://github.com/sethvargo))
- Speed up Lockfile feature [\#559](https://github.com/berkshelf/berkshelf/pull/559) ([sethvargo](https://github.com/sethvargo))
- Allow user to specify licenses [\#543](https://github.com/berkshelf/berkshelf/pull/543) ([sethvargo](https://github.com/sethvargo))
- Cookbook validation should be performed on `package` command [\#536](https://github.com/berkshelf/berkshelf/pull/536) ([reset](https://github.com/reset))

## [v1.4.5](https://github.com/berkshelf/berkshelf/tree/v1.4.5) (2013-05-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.0.beta...v1.4.5)

**Merged pull requests:**

- json parsing middleware registerd as :parse\_json in Ridley 0.12.4 [\#582](https://github.com/berkshelf/berkshelf/pull/582) ([reset](https://github.com/reset))
- Fix link to vagrant-berkshelf [\#578](https://github.com/berkshelf/berkshelf/pull/578) ([sethvargo](https://github.com/sethvargo))
- Remove autoload [\#572](https://github.com/berkshelf/berkshelf/pull/572) ([sethvargo](https://github.com/sethvargo))
- Remove json\_spec as a dependency \(we aren't using it\) [\#570](https://github.com/berkshelf/berkshelf/pull/570) ([sethvargo](https://github.com/sethvargo))
- Run all tests on Travis [\#568](https://github.com/berkshelf/berkshelf/pull/568) ([sethvargo](https://github.com/sethvargo))
- Speed up Vendor feature [\#567](https://github.com/berkshelf/berkshelf/pull/567) ([sethvargo](https://github.com/sethvargo))
- Speed up Upload feature [\#566](https://github.com/berkshelf/berkshelf/pull/566) ([sethvargo](https://github.com/sethvargo))
- Speed up Update feature [\#565](https://github.com/berkshelf/berkshelf/pull/565) ([sethvargo](https://github.com/sethvargo))
- Speed up Package feature [\#562](https://github.com/berkshelf/berkshelf/pull/562) ([sethvargo](https://github.com/sethvargo))
- Speed up Outdated command [\#561](https://github.com/berkshelf/berkshelf/pull/561) ([sethvargo](https://github.com/sethvargo))
- Speed up Open feature [\#560](https://github.com/berkshelf/berkshelf/pull/560) ([sethvargo](https://github.com/sethvargo))
- Speed up List feature [\#558](https://github.com/berkshelf/berkshelf/pull/558) ([sethvargo](https://github.com/sethvargo))
- Speed up Groups feature [\#557](https://github.com/berkshelf/berkshelf/pull/557) ([sethvargo](https://github.com/sethvargo))
- Speed up Cookbook feature [\#556](https://github.com/berkshelf/berkshelf/pull/556) ([sethvargo](https://github.com/sethvargo))
- Speed up Contingent feature [\#555](https://github.com/berkshelf/berkshelf/pull/555) ([sethvargo](https://github.com/sethvargo))
- Speed up Configure feature [\#554](https://github.com/berkshelf/berkshelf/pull/554) ([sethvargo](https://github.com/sethvargo))
- Speed up Config feature [\#553](https://github.com/berkshelf/berkshelf/pull/553) ([sethvargo](https://github.com/sethvargo))
- Speed up Apply feature [\#552](https://github.com/berkshelf/berkshelf/pull/552) ([sethvargo](https://github.com/sethvargo))
- Move Gemfile development dependencies to gemspec [\#551](https://github.com/berkshelf/berkshelf/pull/551) ([sethvargo](https://github.com/sethvargo))
- Fix failing specs and features [\#550](https://github.com/berkshelf/berkshelf/pull/550) ([sethvargo](https://github.com/sethvargo))
- Fix CZ on master [\#546](https://github.com/berkshelf/berkshelf/pull/546) ([sethvargo](https://github.com/sethvargo))
- Only set the path option if it existed when parsing a legacy lockfile [\#544](https://github.com/berkshelf/berkshelf/pull/544) ([sethvargo](https://github.com/sethvargo))
- Warn if spaces [\#534](https://github.com/berkshelf/berkshelf/pull/534) ([sethvargo](https://github.com/sethvargo))
- Lockfile fixes [\#533](https://github.com/berkshelf/berkshelf/pull/533) ([sethvargo](https://github.com/sethvargo))
- Remove alias\_method on UI module [\#527](https://github.com/berkshelf/berkshelf/pull/527) ([sethvargo](https://github.com/sethvargo))
- version numbers must be strings to prevent environment.save crash [\#521](https://github.com/berkshelf/berkshelf/pull/521) ([timops](https://github.com/timops))
- Default locations are broken [\#516](https://github.com/berkshelf/berkshelf/pull/516) ([sethvargo](https://github.com/sethvargo))

## [v2.0.0.beta](https://github.com/berkshelf/berkshelf/tree/v2.0.0.beta) (2013-05-15)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.4...v2.0.0.beta)

**Merged pull requests:**

- Fix tests [\#515](https://github.com/berkshelf/berkshelf/pull/515) ([sethvargo](https://github.com/sethvargo))
- Implement `berks package` [\#510](https://github.com/berkshelf/berkshelf/pull/510) ([sethvargo](https://github.com/sethvargo))
- Test-Kitchen integration [\#435](https://github.com/berkshelf/berkshelf/pull/435) ([reset](https://github.com/reset))

## [v1.4.4](https://github.com/berkshelf/berkshelf/tree/v1.4.4) (2013-05-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.3...v1.4.4)

**Merged pull requests:**

- bump required ridley version to 0.12.1 [\#513](https://github.com/berkshelf/berkshelf/pull/513) ([reset](https://github.com/reset))
- Don't assume Thor::Shell::Color [\#507](https://github.com/berkshelf/berkshelf/pull/507) ([sethvargo](https://github.com/sethvargo))
- Use Celluloid Futures to load the CookbookStore [\#506](https://github.com/berkshelf/berkshelf/pull/506) ([sethvargo](https://github.com/sethvargo))
- Accept Berkshelf configurations from other paths \(\#476\) [\#505](https://github.com/berkshelf/berkshelf/pull/505) ([sethvargo](https://github.com/sethvargo))
- Use formatters everywhere for output [\#503](https://github.com/berkshelf/berkshelf/pull/503) ([sethvargo](https://github.com/sethvargo))
- Warn if CookbookSource\#name is different from the metadata name [\#502](https://github.com/berkshelf/berkshelf/pull/502) ([sethvargo](https://github.com/sethvargo))
- Refactor Specs [\#501](https://github.com/berkshelf/berkshelf/pull/501) ([sethvargo](https://github.com/sethvargo))

## [v1.4.3](https://github.com/berkshelf/berkshelf/tree/v1.4.3) (2013-05-09)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.2...v1.4.3)

**Merged pull requests:**

- Just use JSON [\#491](https://github.com/berkshelf/berkshelf/pull/491) ([sethvargo](https://github.com/sethvargo))
- git SHA should be resolved in lockfile [\#486](https://github.com/berkshelf/berkshelf/pull/486) ([sethvargo](https://github.com/sethvargo))
- berks apply command [\#473](https://github.com/berkshelf/berkshelf/pull/473) ([capoferro](https://github.com/capoferro))
- Is there any config file for author name/email to populate while creating cookbook? [\#391](https://github.com/berkshelf/berkshelf/pull/391) ([millisami](https://github.com/millisami))

## [v1.4.2](https://github.com/berkshelf/berkshelf/tree/v1.4.2) (2013-05-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.1...v1.4.2)

**Merged pull requests:**

- Fix Git caching [\#484](https://github.com/berkshelf/berkshelf/pull/484) ([ivey](https://github.com/ivey))
- Fix `berks open` features when $VISUAL is set [\#483](https://github.com/berkshelf/berkshelf/pull/483) ([ivey](https://github.com/ivey))
- Lockfile 2.0 - cleaned branch [\#481](https://github.com/berkshelf/berkshelf/pull/481) ([reset](https://github.com/reset))

## [v1.4.1](https://github.com/berkshelf/berkshelf/tree/v1.4.1) (2013-04-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.0...v1.4.1)

**Merged pull requests:**

- chef\_server\_url not configurable for upload command [\#480](https://github.com/berkshelf/berkshelf/pull/480) ([KAllan357](https://github.com/KAllan357))
- Re-think \#463? [\#472](https://github.com/berkshelf/berkshelf/pull/472) ([sethvargo](https://github.com/sethvargo))
- Fix the failing cucumber scenaiors [\#471](https://github.com/berkshelf/berkshelf/pull/471) ([sethvargo](https://github.com/sethvargo))
- Doc SSL issues - \#380 [\#470](https://github.com/berkshelf/berkshelf/pull/470) ([ivey](https://github.com/ivey))
- Init Error [\#468](https://github.com/berkshelf/berkshelf/pull/468) ([kbacha](https://github.com/kbacha))
- Update CLI example for 'berks cookbook'  [\#466](https://github.com/berkshelf/berkshelf/pull/466) ([jastix](https://github.com/jastix))
- Validate the shortname for 'site' [\#465](https://github.com/berkshelf/berkshelf/pull/465) ([capoferro](https://github.com/capoferro))
- Create Plugin List [\#459](https://github.com/berkshelf/berkshelf/pull/459) ([sethvargo](https://github.com/sethvargo))

## [v1.4.0](https://github.com/berkshelf/berkshelf/tree/v1.4.0) (2013-04-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.0.rc1...v1.4.0)

**Merged pull requests:**

- path source should expand from Berksfile location and now CWD [\#463](https://github.com/berkshelf/berkshelf/pull/463) ([reset](https://github.com/reset))
- add addressable gem dependency to gemspec and explicitly require it [\#461](https://github.com/berkshelf/berkshelf/pull/461) ([reset](https://github.com/reset))
- Enable berkshelf-vagrant by default [\#457](https://github.com/berkshelf/berkshelf/pull/457) ([danshultz](https://github.com/danshultz))
- Thor 0.18 [\#456](https://github.com/berkshelf/berkshelf/pull/456) ([justincampbell](https://github.com/justincampbell))
- Fix specs - look in right place for testing knife.rb [\#454](https://github.com/berkshelf/berkshelf/pull/454) ([ivey](https://github.com/ivey))
- Support plain .tar cookbooks as well as .tar.gz cookbooks. [\#452](https://github.com/berkshelf/berkshelf/pull/452) ([hnakamur](https://github.com/hnakamur))
- Fix rspec dependency [\#451](https://github.com/berkshelf/berkshelf/pull/451) ([justincampbell](https://github.com/justincampbell))
- Always uploads to chef\_api defined org, rather than knife defined org [\#446](https://github.com/berkshelf/berkshelf/pull/446) ([bakins](https://github.com/bakins))
- require a cookbook name argument in show command [\#444](https://github.com/berkshelf/berkshelf/pull/444) ([reset](https://github.com/reset))
- require 'cookbook' argument on contingent command [\#443](https://github.com/berkshelf/berkshelf/pull/443) ([reset](https://github.com/reset))
- 208 no bundler test [\#422](https://github.com/berkshelf/berkshelf/pull/422) ([sethvargo](https://github.com/sethvargo))
- Support for generating cookbooks with chef-minitest [\#401](https://github.com/berkshelf/berkshelf/pull/401) ([charlesjohnson](https://github.com/charlesjohnson))
- Search for the knife.rb like chef does [\#383](https://github.com/berkshelf/berkshelf/pull/383) ([sethvargo](https://github.com/sethvargo))
- Add berks contingent command [\#365](https://github.com/berkshelf/berkshelf/pull/365) ([sethvargo](https://github.com/sethvargo))
- Add berks info command [\#364](https://github.com/berkshelf/berkshelf/pull/364) ([sethvargo](https://github.com/sethvargo))

## [v1.4.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.4.0.rc1) (2013-03-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.3.1...v1.4.0.rc1)

**Merged pull requests:**

- add logging mixin and refactor Berkshelf.log into Berkshelf::Logger [\#434](https://github.com/berkshelf/berkshelf/pull/434) ([reset](https://github.com/reset))
- Automatically freeze cookbooks on upload [\#431](https://github.com/berkshelf/berkshelf/pull/431) ([reset](https://github.com/reset))
- remove facter language override prevention hack [\#428](https://github.com/berkshelf/berkshelf/pull/428) ([reset](https://github.com/reset))
- Attempt \#2 at \#399 \(use local cache\) [\#415](https://github.com/berkshelf/berkshelf/pull/415) ([sethvargo](https://github.com/sethvargo))

## [v1.3.1](https://github.com/berkshelf/berkshelf/tree/v1.3.1) (2013-03-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.3.0...v1.3.1)

**Merged pull requests:**

- rescue if the cookbook has not been uploaded at all [\#405](https://github.com/berkshelf/berkshelf/pull/405) ([bakins](https://github.com/bakins))

## [v1.3.0](https://github.com/berkshelf/berkshelf/tree/v1.3.0) (2013-03-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.3.0.rc1...v1.3.0)

**Merged pull requests:**

- relax required ruby ver back to \>= 1.9.1 [\#427](https://github.com/berkshelf/berkshelf/pull/427) ([reset](https://github.com/reset))
- add -d flag to enable debug output [\#426](https://github.com/berkshelf/berkshelf/pull/426) ([reset](https://github.com/reset))
- explicitly lock supported rubies [\#425](https://github.com/berkshelf/berkshelf/pull/425) ([reset](https://github.com/reset))
- bug fixes in cookbook transfers [\#424](https://github.com/berkshelf/berkshelf/pull/424) ([reset](https://github.com/reset))

## [v1.3.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.3.0.rc1) (2013-03-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.2.1...v1.3.0.rc1)

**Merged pull requests:**

- remove vagrant plugin from berkshelf core [\#423](https://github.com/berkshelf/berkshelf/pull/423) ([reset](https://github.com/reset))
- Require Ridley 0.8.5 [\#420](https://github.com/berkshelf/berkshelf/pull/420) ([justincampbell](https://github.com/justincampbell))
- Rubygems via https [\#417](https://github.com/berkshelf/berkshelf/pull/417) ([Spikels](https://github.com/Spikels))
- Attempt to speed up tests [\#414](https://github.com/berkshelf/berkshelf/pull/414) ([sethvargo](https://github.com/sethvargo))
- Fix travis [\#413](https://github.com/berkshelf/berkshelf/pull/413) ([sethvargo](https://github.com/sethvargo))
- Behave more like a linux-based CLI: [\#412](https://github.com/berkshelf/berkshelf/pull/412) ([sethvargo](https://github.com/sethvargo))
- Ensure the git user is set during CI [\#406](https://github.com/berkshelf/berkshelf/pull/406) ([justincampbell](https://github.com/justincampbell))
- Replace underscores for hostnames in Vagrantfile [\#402](https://github.com/berkshelf/berkshelf/pull/402) ([rb2k](https://github.com/rb2k))
- Use uniform .ruby-version file [\#398](https://github.com/berkshelf/berkshelf/pull/398) ([stevenhaddox](https://github.com/stevenhaddox))

## [v1.2.1](https://github.com/berkshelf/berkshelf/tree/v1.2.1) (2013-03-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/berkshelf/berkshelf/tree/v1.2.0) (2013-03-05)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.2.0.rc1...v1.2.0)

**Merged pull requests:**

- Look locally for cached cookbooks [\#395](https://github.com/berkshelf/berkshelf/pull/395) ([sethvargo](https://github.com/sethvargo))
- add knife option so some knife.rb options will work [\#394](https://github.com/berkshelf/berkshelf/pull/394) ([bakins](https://github.com/bakins))
- Add named anchors to \#\# headings. [\#390](https://github.com/berkshelf/berkshelf/pull/390) ([jhowarth](https://github.com/jhowarth))
- add HTTP retries to downloading and uploading cookbooks [\#389](https://github.com/berkshelf/berkshelf/pull/389) ([reset](https://github.com/reset))
- remove uploader [\#388](https://github.com/berkshelf/berkshelf/pull/388) ([reset](https://github.com/reset))
- Fixing Git support for sha, tag, branch [\#387](https://github.com/berkshelf/berkshelf/pull/387) ([ryansch](https://github.com/ryansch))
- add helpful error message for loading the berkshelf plugin [\#385](https://github.com/berkshelf/berkshelf/pull/385) ([reset](https://github.com/reset))
- generated Gemfile should not include Vagrant dependency [\#375](https://github.com/berkshelf/berkshelf/pull/375) ([reset](https://github.com/reset))
- Resolver should error if incompatible dependencies are specified [\#366](https://github.com/berkshelf/berkshelf/pull/366) ([ivey](https://github.com/ivey))

## [v1.2.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.2.0.rc1) (2013-02-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.6...v1.2.0.rc1)

**Merged pull requests:**

- Autocreate git remotes [\#367](https://github.com/berkshelf/berkshelf/pull/367) ([capoferro](https://github.com/capoferro))
- Add debugging output [\#360](https://github.com/berkshelf/berkshelf/pull/360) ([sethvargo](https://github.com/sethvargo))
- Move vagrant development dependency to gemspec [\#356](https://github.com/berkshelf/berkshelf/pull/356) ([reset](https://github.com/reset))
- backout PR \#298 [\#355](https://github.com/berkshelf/berkshelf/pull/355) ([reset](https://github.com/reset))
- Git spec cleanup [\#352](https://github.com/berkshelf/berkshelf/pull/352) ([capoferro](https://github.com/capoferro))
- remove dependency on Chef gem [\#342](https://github.com/berkshelf/berkshelf/pull/342) ([reset](https://github.com/reset))
- Remove unnecessary hard dependency on $HOME being set [\#340](https://github.com/berkshelf/berkshelf/pull/340) ([blasdelf](https://github.com/blasdelf))
- Bash completion for cookbooks [\#337](https://github.com/berkshelf/berkshelf/pull/337) ([sethvargo](https://github.com/sethvargo))
- Like bundler, berks should default do berks install [\#336](https://github.com/berkshelf/berkshelf/pull/336) ([sethvargo](https://github.com/sethvargo))
- Add Cane [\#333](https://github.com/berkshelf/berkshelf/pull/333) ([justincampbell](https://github.com/justincampbell))
- Loading berkshelf sets locale to C [\#270](https://github.com/berkshelf/berkshelf/pull/270) ([sciurus](https://github.com/sciurus))

## [v1.1.6](https://github.com/berkshelf/berkshelf/tree/v1.1.6) (2013-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.5...v1.1.6)

**Merged pull requests:**

- Move moneta from Gemfile to gemspec [\#350](https://github.com/berkshelf/berkshelf/pull/350) ([reset](https://github.com/reset))
- add vagrant to development and test gem group [\#344](https://github.com/berkshelf/berkshelf/pull/344) ([reset](https://github.com/reset))

## [v1.1.5](https://github.com/berkshelf/berkshelf/tree/v1.1.5) (2013-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.4...v1.1.5)

**Merged pull requests:**

- JSON \(in\)sanity [\#339](https://github.com/berkshelf/berkshelf/pull/339) ([reset](https://github.com/reset))
- Berkshelf gem should not depend on Vagrant gem [\#288](https://github.com/berkshelf/berkshelf/pull/288) ([charlesjohnson](https://github.com/charlesjohnson))

## [v1.1.4](https://github.com/berkshelf/berkshelf/tree/v1.1.4) (2013-02-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.3...v1.1.4)

**Merged pull requests:**

- fix broken configure features [\#338](https://github.com/berkshelf/berkshelf/pull/338) ([reset](https://github.com/reset))
- Merge 1-1-stable into master [\#334](https://github.com/berkshelf/berkshelf/pull/334) ([justincampbell](https://github.com/justincampbell))
- Clarify language in Vagrantfile [\#331](https://github.com/berkshelf/berkshelf/pull/331) ([sethvargo](https://github.com/sethvargo))

## [v1.1.3](https://github.com/berkshelf/berkshelf/tree/v1.1.3) (2013-02-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.2...v1.1.3)

**Merged pull requests:**

- Add score to Code Climate badge [\#329](https://github.com/berkshelf/berkshelf/pull/329) ([justincampbell](https://github.com/justincampbell))
- Fix for chef 11 [\#328](https://github.com/berkshelf/berkshelf/pull/328) ([reset](https://github.com/reset))
- Test against multiple Chef versions [\#326](https://github.com/berkshelf/berkshelf/pull/326) ([sethvargo](https://github.com/sethvargo))
- update email addresses of riot contributors [\#324](https://github.com/berkshelf/berkshelf/pull/324) ([reset](https://github.com/reset))
- Enable Guard notifications [\#317](https://github.com/berkshelf/berkshelf/pull/317) ([justincampbell](https://github.com/justincampbell))
- Make Berkshelf threadsafe \(again\) [\#316](https://github.com/berkshelf/berkshelf/pull/316) ([sethvargo](https://github.com/sethvargo))
- Read maintainer info from Berkshelf::Config [\#315](https://github.com/berkshelf/berkshelf/pull/315) ([sethvargo](https://github.com/sethvargo))
- Convert UI to Module [\#314](https://github.com/berkshelf/berkshelf/pull/314) ([sethvargo](https://github.com/sethvargo))
- If a relative :path is in Berksfile, keep it relative in Berksfile.lock. [\#310](https://github.com/berkshelf/berkshelf/pull/310) ([rectalogic](https://github.com/rectalogic))
- Ignore Bundler binstub-generated directories [\#309](https://github.com/berkshelf/berkshelf/pull/309) ([schisamo](https://github.com/schisamo))
- Fix \(some\) failing specs [\#307](https://github.com/berkshelf/berkshelf/pull/307) ([reset](https://github.com/reset))
- Please add a Changelog file [\#305](https://github.com/berkshelf/berkshelf/pull/305) ([tmatilai](https://github.com/tmatilai))
- use latest version of Ridley [\#303](https://github.com/berkshelf/berkshelf/pull/303) ([reset](https://github.com/reset))
- Use berksfile for dependency resolution [\#302](https://github.com/berkshelf/berkshelf/pull/302) ([chrisroberts](https://github.com/chrisroberts))
- Set metadata name if metadata name is not set [\#301](https://github.com/berkshelf/berkshelf/pull/301) ([chrisroberts](https://github.com/chrisroberts))
- Allow cookbook uploads without dependency resolution. Add spec. [\#300](https://github.com/berkshelf/berkshelf/pull/300) ([chrisroberts](https://github.com/chrisroberts))
- Raise an exception if the berkshelf directory is not writable [\#299](https://github.com/berkshelf/berkshelf/pull/299) ([sethvargo](https://github.com/sethvargo))
- Lockfile management and DEBUG flags [\#298](https://github.com/berkshelf/berkshelf/pull/298) ([sethvargo](https://github.com/sethvargo))
- Allow cookbook uploads without dependency resolution. Add spec. [\#296](https://github.com/berkshelf/berkshelf/pull/296) ([chrisroberts](https://github.com/chrisroberts))
- Support --quiet option [\#292](https://github.com/berkshelf/berkshelf/pull/292) ([sethvargo](https://github.com/sethvargo))

## [v1.1.2](https://github.com/berkshelf/berkshelf/tree/v1.1.2) (2013-01-10)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.1...v1.1.2)

**Merged pull requests:**

- Resolves issue \#286 [\#287](https://github.com/berkshelf/berkshelf/pull/287) ([arangamani](https://github.com/arangamani))
- Add development steps to CONTRIBUTING.md [\#280](https://github.com/berkshelf/berkshelf/pull/280) ([justincampbell](https://github.com/justincampbell))

## [v1.1.1](https://github.com/berkshelf/berkshelf/tree/v1.1.1) (2013-01-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- Add option to skip ruby syntax check on upload [\#283](https://github.com/berkshelf/berkshelf/pull/283) ([reset](https://github.com/reset))
- fix our failing tests [\#282](https://github.com/berkshelf/berkshelf/pull/282) ([reset](https://github.com/reset))
- Add more files and patterns to chefignore. [\#281](https://github.com/berkshelf/berkshelf/pull/281) ([sethvargo](https://github.com/sethvargo))
- Add 'test/\*' to chefignore generator file. [\#279](https://github.com/berkshelf/berkshelf/pull/279) ([fnichol](https://github.com/fnichol))
- Add IRC notifications for Travis CI [\#277](https://github.com/berkshelf/berkshelf/pull/277) ([justincampbell](https://github.com/justincampbell))
- bump ridley version and use improvements in uploader [\#276](https://github.com/berkshelf/berkshelf/pull/276) ([reset](https://github.com/reset))
- Allow wider range of repository URIs \(\#257\) [\#265](https://github.com/berkshelf/berkshelf/pull/265) ([aflatter](https://github.com/aflatter))
- Create CONTRIBUTING.md [\#262](https://github.com/berkshelf/berkshelf/pull/262) ([dwradcliffe](https://github.com/dwradcliffe))

## [v1.1.0](https://github.com/berkshelf/berkshelf/tree/v1.1.0) (2012-12-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.0.rc1...v1.1.0)

**Merged pull requests:**

- lock the ohai version in install\_command.feature to prevent future test failures [\#260](https://github.com/berkshelf/berkshelf/pull/260) ([sethvargo](https://github.com/sethvargo))
- Honor chefignore when vendorizing cookbooks [\#256](https://github.com/berkshelf/berkshelf/pull/256) ([sethvargo](https://github.com/sethvargo))
- Create `berks open` [\#254](https://github.com/berkshelf/berkshelf/pull/254) ([sethvargo](https://github.com/sethvargo))

## [v1.1.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.1.0.rc1) (2012-11-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.4...v1.1.0.rc1)

**Merged pull requests:**

- More verbose outdated [\#255](https://github.com/berkshelf/berkshelf/pull/255) ([reset](https://github.com/reset))
- Add berks outdated command [\#252](https://github.com/berkshelf/berkshelf/pull/252) ([sethvargo](https://github.com/sethvargo))
- Raise a Berkshelf::CookbookNotFound error when trying to update a cookbook that is not in any of the sources [\#251](https://github.com/berkshelf/berkshelf/pull/251) ([sethvargo](https://github.com/sethvargo))
- "cookbook" argument is no longer optional for show command [\#246](https://github.com/berkshelf/berkshelf/pull/246) ([reset](https://github.com/reset))
- use File.open instead of File.write [\#245](https://github.com/berkshelf/berkshelf/pull/245) ([reset](https://github.com/reset))
- better errors in Vagrant plugin [\#244](https://github.com/berkshelf/berkshelf/pull/244) ([reset](https://github.com/reset))
- Better list and show output [\#241](https://github.com/berkshelf/berkshelf/pull/241) ([sethvargo](https://github.com/sethvargo))
- Allow the same cookbook in different groups [\#240](https://github.com/berkshelf/berkshelf/pull/240) ([sethvargo](https://github.com/sethvargo))
- Allow updating of a single cookbook [\#239](https://github.com/berkshelf/berkshelf/pull/239) ([sethvargo](https://github.com/sethvargo))
- Fix \#232 by merging with Thor options [\#238](https://github.com/berkshelf/berkshelf/pull/238) ([sethvargo](https://github.com/sethvargo))
- Add rvmrc [\#237](https://github.com/berkshelf/berkshelf/pull/237) ([sethvargo](https://github.com/sethvargo))
- Allow uploading one \(or more\) cookbooks [\#234](https://github.com/berkshelf/berkshelf/pull/234) ([sethvargo](https://github.com/sethvargo))
- `berks show` to look at a cookbook's location [\#219](https://github.com/berkshelf/berkshelf/pull/219) ([sethvargo](https://github.com/sethvargo))

## [v1.0.4](https://github.com/berkshelf/berkshelf/tree/v1.0.4) (2012-11-16)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.3...v1.0.4)

## [v1.0.3](https://github.com/berkshelf/berkshelf/tree/v1.0.3) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.2...v1.0.3)

## [v1.0.2](https://github.com/berkshelf/berkshelf/tree/v1.0.2) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/berkshelf/berkshelf/tree/v1.0.1) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0...v1.0.1)

**Merged pull requests:**

- Refactor 213 [\#224](https://github.com/berkshelf/berkshelf/pull/224) ([reset](https://github.com/reset))
- Fix syntax on group example [\#223](https://github.com/berkshelf/berkshelf/pull/223) ([coderanger](https://github.com/coderanger))
- Adds travis testing to docs [\#218](https://github.com/berkshelf/berkshelf/pull/218) ([miketheman](https://github.com/miketheman))
- Adds documentation for GitHub location [\#217](https://github.com/berkshelf/berkshelf/pull/217) ([miketheman](https://github.com/miketheman))
- add detection for git.cmd on the PATH, factor out detection to keep code... [\#216](https://github.com/berkshelf/berkshelf/pull/216) ([tknerr](https://github.com/tknerr))
- Simplifying override of mv to always do cp\_r and rm\_rf [\#214](https://github.com/berkshelf/berkshelf/pull/214) ([temujin9](https://github.com/temujin9))
- Make git clones happen into a stable subfolder, and don't reclone if it exists [\#213](https://github.com/berkshelf/berkshelf/pull/213) ([temujin9](https://github.com/temujin9))
- Further cleanup on options\[:ssl\_verify\] and Berkshelf::Config.instance.ssl.verify [\#212](https://github.com/berkshelf/berkshelf/pull/212) ([temujin9](https://github.com/temujin9))
- Adding :rel to :git resource, for repositories where cookbook is not in the repo root [\#211](https://github.com/berkshelf/berkshelf/pull/211) ([temujin9](https://github.com/temujin9))

## [v1.0.0](https://github.com/berkshelf/berkshelf/tree/v1.0.0) (2012-11-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc3...v1.0.0)

**Merged pull requests:**

- Using FileUtils.mv rather than File.rename fixes RiotGames/berkshelf\#209 [\#210](https://github.com/berkshelf/berkshelf/pull/210) ([tknerr](https://github.com/tknerr))
- Github location \(Issue \#64\) [\#206](https://github.com/berkshelf/berkshelf/pull/206) ([capoferro](https://github.com/capoferro))
- Check if options are supported \(Issue \#170\) [\#204](https://github.com/berkshelf/berkshelf/pull/204) ([capoferro](https://github.com/capoferro))

## [v1.0.0.rc3](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc3) (2012-11-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc2...v1.0.0.rc3)

**Merged pull requests:**

- organization is now automatically inferred by server\_url in Ridley [\#205](https://github.com/berkshelf/berkshelf/pull/205) ([reset](https://github.com/reset))
- coerce value for vagrant.cookbooks\_path to an array if it is not one [\#203](https://github.com/berkshelf/berkshelf/pull/203) ([reset](https://github.com/reset))
- `berks upload` should read the knife.rb, if present [\#202](https://github.com/berkshelf/berkshelf/pull/202) ([sethvargo](https://github.com/sethvargo))
- Specifying -c or --config during `berks upload` does nothing... [\#201](https://github.com/berkshelf/berkshelf/pull/201) ([sethvargo](https://github.com/sethvargo))
- Allow config file to set ssl.verify usefully [\#200](https://github.com/berkshelf/berkshelf/pull/200) ([temujin9](https://github.com/temujin9))
- Allowing Berkshelf::Config.path override [\#199](https://github.com/berkshelf/berkshelf/pull/199) ([temujin9](https://github.com/temujin9))
- Disable default bridged networking [\#198](https://github.com/berkshelf/berkshelf/pull/198) ([someara](https://github.com/someara))
- Default cookbook version [\#197](https://github.com/berkshelf/berkshelf/pull/197) ([someara](https://github.com/someara))
- adding .rbenv-version to gitignore [\#196](https://github.com/berkshelf/berkshelf/pull/196) ([someara](https://github.com/someara))

## [v1.0.0.rc2](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc2) (2012-11-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc1...v1.0.0.rc2)

**Merged pull requests:**

- ChefAPI Download bug [\#195](https://github.com/berkshelf/berkshelf/pull/195) ([reset](https://github.com/reset))
- Code cleanup [\#192](https://github.com/berkshelf/berkshelf/pull/192) ([justincampbell](https://github.com/justincampbell))

## [v1.0.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc1) (2012-11-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta4...v1.0.0.rc1)

**Merged pull requests:**

- add Cli\#configure function for interactively configuring Berkshelf [\#187](https://github.com/berkshelf/berkshelf/pull/187) ([reset](https://github.com/reset))

## [v0.6.0.beta4](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta4) (2012-11-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta3...v0.6.0.beta4)

**Merged pull requests:**

- simplify configuration generation, validation, and defaults [\#186](https://github.com/berkshelf/berkshelf/pull/186) ([reset](https://github.com/reset))
- Dir.glob does not support backslash as a File separator, even on Windows... [\#183](https://github.com/berkshelf/berkshelf/pull/183) ([jdutton](https://github.com/jdutton))
- Fix regression \(infinite recursion on Windows\) in 4ad97d4 [\#182](https://github.com/berkshelf/berkshelf/pull/182) ([jdutton](https://github.com/jdutton))
- Organize gemdeps [\#180](https://github.com/berkshelf/berkshelf/pull/180) ([reset](https://github.com/reset))
- fixes issue 158 - init command accepts and uses the generator flags [\#179](https://github.com/berkshelf/berkshelf/pull/179) ([reset](https://github.com/reset))

## [v0.6.0.beta3](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta3) (2012-10-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta2...v0.6.0.beta3)

**Merged pull requests:**

- refactor 140pr to use re-defined FileUtils.mv to fix windows support [\#178](https://github.com/berkshelf/berkshelf/pull/178) ([reset](https://github.com/reset))
- fix issue where FileUtils.mv fails on some Windows machines [\#176](https://github.com/berkshelf/berkshelf/pull/176) ([tknerr](https://github.com/tknerr))
- Fix :git access on Windows [\#175](https://github.com/berkshelf/berkshelf/pull/175) ([jdutton](https://github.com/jdutton))
- Touch metadata.rb before berk init [\#174](https://github.com/berkshelf/berkshelf/pull/174) ([justincampbell](https://github.com/justincampbell))
- Fix git and vagrant flags [\#173](https://github.com/berkshelf/berkshelf/pull/173) ([justincampbell](https://github.com/justincampbell))
- Make Git and Vagrant the defaults [\#172](https://github.com/berkshelf/berkshelf/pull/172) ([justincampbell](https://github.com/justincampbell))
- Use Travis CI [\#171](https://github.com/berkshelf/berkshelf/pull/171) ([justincampbell](https://github.com/justincampbell))
- Add additional options to the Berkshelf config [\#169](https://github.com/berkshelf/berkshelf/pull/169) ([justincampbell](https://github.com/justincampbell))
- Remove Vagrant auto-require hook [\#168](https://github.com/berkshelf/berkshelf/pull/168) ([justincampbell](https://github.com/justincampbell))
- Add support for a Berkshelf config file [\#162](https://github.com/berkshelf/berkshelf/pull/162) ([justincampbell](https://github.com/justincampbell))
- Ignore all \*.pem files [\#160](https://github.com/berkshelf/berkshelf/pull/160) ([justincampbell](https://github.com/justincampbell))
- Before download errors, output source and location [\#159](https://github.com/berkshelf/berkshelf/pull/159) ([justincampbell](https://github.com/justincampbell))
- Use :rubygems symbol in generated Gemfile [\#157](https://github.com/berkshelf/berkshelf/pull/157) ([justincampbell](https://github.com/justincampbell))
- Refactoring Downloader [\#156](https://github.com/berkshelf/berkshelf/pull/156) ([justincampbell](https://github.com/justincampbell))
- Failing specs [\#155](https://github.com/berkshelf/berkshelf/pull/155) ([justincampbell](https://github.com/justincampbell))
- Allow customization of generated Vagrantfile [\#153](https://github.com/berkshelf/berkshelf/pull/153) ([justincampbell](https://github.com/justincampbell))
- Require chef before everything else, sort requires [\#149](https://github.com/berkshelf/berkshelf/pull/149) ([justincampbell](https://github.com/justincampbell))

## [v0.6.0.beta2](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta2) (2012-09-28)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.1...v0.6.0.beta2)

## [v0.5.1](https://github.com/berkshelf/berkshelf/tree/v0.5.1) (2012-09-28)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta1...v0.5.1)

**Merged pull requests:**

- Multi vm [\#143](https://github.com/berkshelf/berkshelf/pull/143) ([reset](https://github.com/reset))
- Copy Cookbook Dir Contents Instead of Cookbook Dir Itself [\#142](https://github.com/berkshelf/berkshelf/pull/142) ([RoboticCheese](https://github.com/RoboticCheese))

## [v0.6.0.beta1](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta1) (2012-09-25)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0...v0.6.0.beta1)

**Merged pull requests:**

- use the latest version of Solve [\#136](https://github.com/berkshelf/berkshelf/pull/136) ([reset](https://github.com/reset))

## [v0.5.0](https://github.com/berkshelf/berkshelf/tree/v0.5.0) (2012-09-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc4...v0.5.0)

## [v0.5.0.rc4](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc4) (2012-09-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc3...v0.5.0.rc4)

## [v0.5.0.rc3](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc3) (2012-09-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc2...v0.5.0.rc3)

**Merged pull requests:**

- add ability to disable SSL verification in uploads [\#135](https://github.com/berkshelf/berkshelf/pull/135) ([reset](https://github.com/reset))
- fix uploads when using chef\_client provisioner [\#134](https://github.com/berkshelf/berkshelf/pull/134) ([reset](https://github.com/reset))
- Pages 5 [\#133](https://github.com/berkshelf/berkshelf/pull/133) ([reset](https://github.com/reset))

## [v0.5.0.rc2](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc2) (2012-09-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc1...v0.5.0.rc2)

## [v0.5.0.rc1](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc1) (2012-09-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0...v0.5.0.rc1)

**Merged pull requests:**

- Ui class [\#132](https://github.com/berkshelf/berkshelf/pull/132) ([reset](https://github.com/reset))
- use the Berkshelf.ui output Vagrant info [\#131](https://github.com/berkshelf/berkshelf/pull/131) ([reset](https://github.com/reset))
- make sources and locations serializable into hash/json [\#129](https://github.com/berkshelf/berkshelf/pull/129) ([reset](https://github.com/reset))
- ensure the cookbook retreived by a location matches the name of the source [\#128](https://github.com/berkshelf/berkshelf/pull/128) ([reset](https://github.com/reset))
- Use ridley [\#127](https://github.com/berkshelf/berkshelf/pull/127) ([reset](https://github.com/reset))
- Vplugin bugfix [\#126](https://github.com/berkshelf/berkshelf/pull/126) ([reset](https://github.com/reset))
- vagrant destroy will clean up the plugin's shelf [\#125](https://github.com/berkshelf/berkshelf/pull/125) ([reset](https://github.com/reset))
- Only except [\#124](https://github.com/berkshelf/berkshelf/pull/124) ([reset](https://github.com/reset))
- Vendor install [\#121](https://github.com/berkshelf/berkshelf/pull/121) ([reset](https://github.com/reset))
- remove 'shims' feature [\#120](https://github.com/berkshelf/berkshelf/pull/120) ([reset](https://github.com/reset))
- Vagrant plugin [\#119](https://github.com/berkshelf/berkshelf/pull/119) ([reset](https://github.com/reset))

## [v0.4.0](https://github.com/berkshelf/berkshelf/tree/v0.4.0) (2012-09-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc4...v0.4.0)

**Merged pull requests:**

- remove Berkshelf::DSL and put it's functionality directly in Berksfile [\#118](https://github.com/berkshelf/berkshelf/pull/118) ([reset](https://github.com/reset))
- if default locations are specified then a downloader will only use those [\#117](https://github.com/berkshelf/berkshelf/pull/117) ([reset](https://github.com/reset))
- treat 'recommends' in cookbook data as dependencies [\#116](https://github.com/berkshelf/berkshelf/pull/116) ([reset](https://github.com/reset))
- add ability to define default locations for a Berksfile [\#115](https://github.com/berkshelf/berkshelf/pull/115) ([reset](https://github.com/reset))
- Refactors for default locations feature [\#114](https://github.com/berkshelf/berkshelf/pull/114) ([reset](https://github.com/reset))
- BERKSHELF-112 ignore temporary editor files [\#112](https://github.com/berkshelf/berkshelf/pull/112) ([bryanwb](https://github.com/bryanwb))
- A couple cleanups [\#110](https://github.com/berkshelf/berkshelf/pull/110) ([matschaffer](https://github.com/matschaffer))

## [v0.4.0.rc4](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc4) (2012-08-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc3...v0.4.0.rc4)

**Merged pull requests:**

- Bump thor for compatibility with test-kitchen [\#109](https://github.com/berkshelf/berkshelf/pull/109) ([matschaffer](https://github.com/matschaffer))
- Formatters [\#108](https://github.com/berkshelf/berkshelf/pull/108) ([ivey](https://github.com/ivey))

## [v0.4.0.rc3](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc3) (2012-08-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc2...v0.4.0.rc3)

**Merged pull requests:**

- Git SSH uri's without organization will now be valid [\#107](https://github.com/berkshelf/berkshelf/pull/107) ([reset](https://github.com/reset))
- Don't checksum the file if it's a broken symlink. [\#102](https://github.com/berkshelf/berkshelf/pull/102) ([capoferro](https://github.com/capoferro))
- Capture errors that occur during berksfile eval to prevent being inadver... [\#101](https://github.com/berkshelf/berkshelf/pull/101) ([capoferro](https://github.com/capoferro))
- move generator files out of ruby load path [\#100](https://github.com/berkshelf/berkshelf/pull/100) ([reset](https://github.com/reset))
- Skip broken symlinks encountered in hardlink traversal. [\#91](https://github.com/berkshelf/berkshelf/pull/91) ([capoferro](https://github.com/capoferro))

## [v0.4.0.rc2](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc2) (2012-07-27)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc1...v0.4.0.rc2)

**Merged pull requests:**

- Trivial changes due to spec update. Also pemfile ignore. [\#97](https://github.com/berkshelf/berkshelf/pull/97) ([capoferro](https://github.com/capoferro))
- Thor::SCMVersion support in generators [\#95](https://github.com/berkshelf/berkshelf/pull/95) ([ivey](https://github.com/ivey))
- -93 [\#94](https://github.com/berkshelf/berkshelf/pull/94) ([lastobelus](https://github.com/lastobelus))
- Update cookbook versions in lockfile\_spec [\#92](https://github.com/berkshelf/berkshelf/pull/92) ([capoferro](https://github.com/capoferro))
- Cookbook command [\#90](https://github.com/berkshelf/berkshelf/pull/90) ([reset](https://github.com/reset))
- Invalid cross-device link during berks install --shims [\#81](https://github.com/berkshelf/berkshelf/pull/81) ([promisedlandt](https://github.com/promisedlandt))

## [v0.4.0.rc1](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc1) (2012-07-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.7...v0.4.0.rc1)

**Merged pull requests:**

- Chef API location [\#87](https://github.com/berkshelf/berkshelf/pull/87) ([reset](https://github.com/reset))
- Site location refactors [\#86](https://github.com/berkshelf/berkshelf/pull/86) ([reset](https://github.com/reset))
- add validation for options in Berksfile [\#84](https://github.com/berkshelf/berkshelf/pull/84) ([reset](https://github.com/reset))
- Replace DepSelector with Solve [\#83](https://github.com/berkshelf/berkshelf/pull/83) ([reset](https://github.com/reset))
- Handle shims dir that's a child of the current dir - closes \#78 [\#80](https://github.com/berkshelf/berkshelf/pull/80) ([ivey](https://github.com/ivey))
- Test fixes [\#79](https://github.com/berkshelf/berkshelf/pull/79) ([ivey](https://github.com/ivey))
- Use knife rb [\#68](https://github.com/berkshelf/berkshelf/pull/68) ([erikh](https://github.com/erikh))

## [v0.3.7](https://github.com/berkshelf/berkshelf/tree/v0.3.7) (2012-07-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.6...v0.3.7)

**Merged pull requests:**

- fix issue when caching git sources with an aliased ref [\#77](https://github.com/berkshelf/berkshelf/pull/77) ([reset](https://github.com/reset))

## [v0.3.6](https://github.com/berkshelf/berkshelf/tree/v0.3.6) (2012-07-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.5...v0.3.6)

**Merged pull requests:**

- fix bug with satisfying git sources that have not been downloaded [\#76](https://github.com/berkshelf/berkshelf/pull/76) ([reset](https://github.com/reset))

## [v0.3.5](https://github.com/berkshelf/berkshelf/tree/v0.3.5) (2012-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.4...v0.3.5)

**Merged pull requests:**

- raise a more helpful error if git execution fails [\#75](https://github.com/berkshelf/berkshelf/pull/75) ([reset](https://github.com/reset))

## [v0.3.4](https://github.com/berkshelf/berkshelf/tree/v0.3.4) (2012-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.3...v0.3.4)

**Merged pull requests:**

- Validate downloaded sources [\#74](https://github.com/berkshelf/berkshelf/pull/74) ([reset](https://github.com/reset))
- shims will be rewritten if write\_shims is called [\#73](https://github.com/berkshelf/berkshelf/pull/73) ([reset](https://github.com/reset))
- Validate Git location sources [\#72](https://github.com/berkshelf/berkshelf/pull/72) ([reset](https://github.com/reset))
- Don't download sources that have already been downloaded [\#71](https://github.com/berkshelf/berkshelf/pull/71) ([reset](https://github.com/reset))
- No require config file [\#69](https://github.com/berkshelf/berkshelf/pull/69) ([erikh](https://github.com/erikh))
- Config file from environment [\#67](https://github.com/berkshelf/berkshelf/pull/67) ([erikh](https://github.com/erikh))

## [v0.3.3](https://github.com/berkshelf/berkshelf/tree/v0.3.3) (2012-06-27)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.2...v0.3.3)

**Merged pull requests:**

- fix infinite loop bug when writing shims of a path location [\#61](https://github.com/berkshelf/berkshelf/pull/61) ([reset](https://github.com/reset))

## [v0.3.2](https://github.com/berkshelf/berkshelf/tree/v0.3.2) (2012-06-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.1...v0.3.2)

**Merged pull requests:**

- fix bug where app wouldn't exit if no remote solution was found [\#60](https://github.com/berkshelf/berkshelf/pull/60) ([reset](https://github.com/reset))

## [v0.3.1](https://github.com/berkshelf/berkshelf/tree/v0.3.1) (2012-06-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.0...v0.3.1)

**Merged pull requests:**

- Berksfile resolve [\#59](https://github.com/berkshelf/berkshelf/pull/59) ([jhowarth](https://github.com/jhowarth))

## [v0.3.0](https://github.com/berkshelf/berkshelf/tree/v0.3.0) (2012-06-25)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.2.0...v0.3.0)

**Merged pull requests:**

- Thor CLI instead of Knife [\#58](https://github.com/berkshelf/berkshelf/pull/58) ([reset](https://github.com/reset))

## [v0.2.0](https://github.com/berkshelf/berkshelf/tree/v0.2.0) (2012-06-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.5...v0.2.0)

**Merged pull requests:**

- added install command --shims flag [\#57](https://github.com/berkshelf/berkshelf/pull/57) ([reset](https://github.com/reset))

## [v0.1.5](https://github.com/berkshelf/berkshelf/tree/v0.1.5) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.4...v0.1.5)

## [v0.1.4](https://github.com/berkshelf/berkshelf/tree/v0.1.4) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.3...v0.1.4)

**Merged pull requests:**

- add includable Thor tasks for Berkshelf [\#56](https://github.com/berkshelf/berkshelf/pull/56) ([reset](https://github.com/reset))

## [v0.1.3](https://github.com/berkshelf/berkshelf/tree/v0.1.3) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.2...v0.1.3)

## [v0.1.2](https://github.com/berkshelf/berkshelf/tree/v0.1.2) (2012-06-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.1...v0.1.2)

**Merged pull requests:**

- Fix uploader bug [\#55](https://github.com/berkshelf/berkshelf/pull/55) ([reset](https://github.com/reset))

## [v0.1.1](https://github.com/berkshelf/berkshelf/tree/v0.1.1) (2012-06-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/berkshelf/berkshelf/tree/v0.1.0) (2012-06-21)
**Merged pull requests:**

- Rename to Berkshelf [\#54](https://github.com/berkshelf/berkshelf/pull/54) ([reset](https://github.com/reset))
- remove "clean" knife command and supporting functionality [\#53](https://github.com/berkshelf/berkshelf/pull/53) ([reset](https://github.com/reset))
- add yarddoc gem and guard-yarddoc [\#50](https://github.com/berkshelf/berkshelf/pull/50) ([reset](https://github.com/reset))
- Add upload command [\#47](https://github.com/berkshelf/berkshelf/pull/47) ([reset](https://github.com/reset))
- lock required ruby version to \>= 1.9.1 [\#45](https://github.com/berkshelf/berkshelf/pull/45) ([reset](https://github.com/reset))
- Add CookbookStore and CachedCookbook classes [\#44](https://github.com/berkshelf/berkshelf/pull/44) ([reset](https://github.com/reset))
- refactor Downloader::Result and ResultSet into a more generalized TXResult [\#43](https://github.com/berkshelf/berkshelf/pull/43) ([reset](https://github.com/reset))
- Large refactor to turn KCD into a Library with a CLI wrapper [\#42](https://github.com/berkshelf/berkshelf/pull/42) ([reset](https://github.com/reset))
- Improved error handling and messages [\#40](https://github.com/berkshelf/berkshelf/pull/40) ([reset](https://github.com/reset))
- Revert "ENV\["TMPDIR"\] is really important for people who don't want to u... [\#39](https://github.com/berkshelf/berkshelf/pull/39) ([erikh](https://github.com/erikh))
- Init command [\#38](https://github.com/berkshelf/berkshelf/pull/38) ([reset](https://github.com/reset))
- ENV\["TMPDIR"\] is really important for people who don't want to use "/tmp... [\#34](https://github.com/berkshelf/berkshelf/pull/34) ([erikh](https://github.com/erikh))
- Fix typo in Readme [\#33](https://github.com/berkshelf/berkshelf/pull/33) ([erikh](https://github.com/erikh))
- Update [\#32](https://github.com/berkshelf/berkshelf/pull/32) ([capoferro](https://github.com/capoferro))
- Clean [\#31](https://github.com/berkshelf/berkshelf/pull/31) ([capoferro](https://github.com/capoferro))
- Remove use of File.write, which was added in 1.9.3. [\#30](https://github.com/berkshelf/berkshelf/pull/30) ([jhowarth](https://github.com/jhowarth))
- Add dependency computation test. [\#29](https://github.com/berkshelf/berkshelf/pull/29) ([jhowarth](https://github.com/jhowarth))
- Remove dependency reader [\#28](https://github.com/berkshelf/berkshelf/pull/28) ([jhowarth](https://github.com/jhowarth))
- Use Chef::Cookbook::Metadata for handling metadata.rb files. [\#27](https://github.com/berkshelf/berkshelf/pull/27) ([jhowarth](https://github.com/jhowarth))
- VCR with dynamic cassette generation [\#25](https://github.com/berkshelf/berkshelf/pull/25) ([capoferro](https://github.com/capoferro))
- fix gitignore and clear shelf when installing multiple times in a single... [\#23](https://github.com/berkshelf/berkshelf/pull/23) ([erikh](https://github.com/erikh))
- Alias itall [\#22](https://github.com/berkshelf/berkshelf/pull/22) ([reset](https://github.com/reset))
- Lock tests [\#21](https://github.com/berkshelf/berkshelf/pull/21) ([erikh](https://github.com/erikh))
- Refactors [\#20](https://github.com/berkshelf/berkshelf/pull/20) ([erikh](https://github.com/erikh))
- not everyone who runs the tests has access to riot github :\) [\#19](https://github.com/berkshelf/berkshelf/pull/19) ([erikh](https://github.com/erikh))
- Groups [\#18](https://github.com/berkshelf/berkshelf/pull/18) ([ivey](https://github.com/ivey))
- Friendly errors [\#17](https://github.com/berkshelf/berkshelf/pull/17) ([capoferro](https://github.com/capoferro))
- Lockfile support [\#13](https://github.com/berkshelf/berkshelf/pull/13) ([erikh](https://github.com/erikh))
- Git ref [\#12](https://github.com/berkshelf/berkshelf/pull/12) ([erikh](https://github.com/erikh))
- Knife plugin [\#11](https://github.com/berkshelf/berkshelf/pull/11) ([erikh](https://github.com/erikh))
- Git support [\#10](https://github.com/berkshelf/berkshelf/pull/10) ([erikh](https://github.com/erikh))
- Path [\#9](https://github.com/berkshelf/berkshelf/pull/9) ([capoferro](https://github.com/capoferro))
- Cookbookfile \> Cheffile to avoid unintentional conflicts with librarian-chef [\#8](https://github.com/berkshelf/berkshelf/pull/8) ([capoferro](https://github.com/capoferro))
- Cookbook refactors [\#7](https://github.com/berkshelf/berkshelf/pull/7) ([erikh](https://github.com/erikh))
- test cleanup: [\#6](https://github.com/berkshelf/berkshelf/pull/6) ([erikh](https://github.com/erikh))
- Fat commit, see comments: [\#5](https://github.com/berkshelf/berkshelf/pull/5) ([erikh](https://github.com/erikh))
- Executable [\#4](https://github.com/berkshelf/berkshelf/pull/4) ([capoferro](https://github.com/capoferro))
- Rdoc readme [\#3](https://github.com/berkshelf/berkshelf/pull/3) ([erikh](https://github.com/erikh))
- Rake checks [\#2](https://github.com/berkshelf/berkshelf/pull/2) ([erikh](https://github.com/erikh))
- gemfile and building gem properly. Version is in lib/remy/version.rb [\#1](https://github.com/berkshelf/berkshelf/pull/1) ([erikh](https://github.com/erikh))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*