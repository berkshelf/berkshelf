# Change Log

## [4.3.2](https://github.com/berkshelf/berkshelf/tree/4.3.2) (2016-04-05)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.1...4.3.2)

**Closed issues:**

- chef\_server source does not work as documented. [\#1540](https://github.com/berkshelf/berkshelf/issues/1540)

## [v4.3.1](https://github.com/berkshelf/berkshelf/tree/v4.3.1) (2016-03-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.3.0...v4.3.1)

**Implemented enhancements:**

- Authenticated universe endpoint in new Chef Server 12.4 [\#1511](https://github.com/berkshelf/berkshelf/issues/1511)

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
- Bump version to 4.2.2 [\#1522](https://github.com/berkshelf/berkshelf/pull/1522) ([jkeiser](https://github.com/jkeiser))

## [v4.2.2](https://github.com/berkshelf/berkshelf/tree/v4.2.2) (2016-02-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.1...v4.2.2)

**Merged pull requests:**

- Pin github\_changelog\_generator [\#1521](https://github.com/berkshelf/berkshelf/pull/1521) ([jkeiser](https://github.com/jkeiser))

## [v4.2.1](https://github.com/berkshelf/berkshelf/tree/v4.2.1) (2016-02-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.2.0...v4.2.1)

**Merged pull requests:**

- updating httpclient version dep to ~\> 2.7.0 [\#1518](https://github.com/berkshelf/berkshelf/pull/1518) ([someara](https://github.com/someara))

## [v4.2.0](https://github.com/berkshelf/berkshelf/tree/v4.2.0) (2016-02-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.1.1...v4.2.0)

**Closed issues:**

- Allow using a test cookbook from a subpath of another cookbook [\#1505](https://github.com/berkshelf/berkshelf/issues/1505)
- Allow one to "berks apply" to a json environment file [\#875](https://github.com/berkshelf/berkshelf/issues/875)

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

**Implemented enhancements:**

- Add functions for automatically generating portions of metadata [\#957](https://github.com/berkshelf/berkshelf/issues/957)
- Add a new `solver` Berksfile DSL option [\#1482](https://github.com/berkshelf/berkshelf/pull/1482) ([martinb3](https://github.com/martinb3))
- Upgrade to solve 2.0 [\#1475](https://github.com/berkshelf/berkshelf/pull/1475) ([jkeiser](https://github.com/jkeiser))
- Have berks install bump only required cookbooks [\#1462](https://github.com/berkshelf/berkshelf/pull/1462) ([FlorentFlament](https://github.com/FlorentFlament))

**Fixed bugs:**

- ERROR -- : Actor crashed!  found while running berks install [\#1418](https://github.com/berkshelf/berkshelf/issues/1418)
- remove berkshelf gem entry in generated Gemfile [\#1485](https://github.com/berkshelf/berkshelf/pull/1485) ([reset](https://github.com/reset))
- Pin aruba to 0.10.2 [\#1484](https://github.com/berkshelf/berkshelf/pull/1484) ([smith](https://github.com/smith))
- Use Net::HTTP.new instead of Net::HTTP.start [\#1467](https://github.com/berkshelf/berkshelf/pull/1467) ([jkeiser](https://github.com/jkeiser))

**Merged pull requests:**

- When doing 'berks install' Lock cookbooks' version according to the lockfile [\#1460](https://github.com/berkshelf/berkshelf/pull/1460) ([FlorentFlament](https://github.com/FlorentFlament))

## [v4.0.1](https://github.com/berkshelf/berkshelf/tree/v4.0.1) (2015-10-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v4.0.0...v4.0.1)

**Fixed bugs:**

- Can no longer install 3.3.0 on Chef 11/Ruby 1.9 [\#1464](https://github.com/berkshelf/berkshelf/issues/1464)

## [v4.0.0](https://github.com/berkshelf/berkshelf/tree/v4.0.0) (2015-10-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.3.0...v4.0.0)

**Closed issues:**

- berks crash parsing attributes in metadata.rb [\#1461](https://github.com/berkshelf/berkshelf/issues/1461)
- Is it possible to write my own `Location`? [\#1455](https://github.com/berkshelf/berkshelf/issues/1455)
- Berkshelf does not respect cookbook locations on dependencies of dependencies [\#1452](https://github.com/berkshelf/berkshelf/issues/1452)
- not able to upload cookbook to chef server via berks upload. [\#1450](https://github.com/berkshelf/berkshelf/issues/1450)
- ERROR -- : Actor crashed! during berks install [\#1449](https://github.com/berkshelf/berkshelf/issues/1449)
- Unit tests fail on master due to new celluloid. [\#1448](https://github.com/berkshelf/berkshelf/issues/1448)
- Resolving cookbook dependencies fills up hard drive [\#1447](https://github.com/berkshelf/berkshelf/issues/1447)
- Berkshelf doesn't recognize SSL bundle overrides [\#1443](https://github.com/berkshelf/berkshelf/issues/1443)
- Can you release a new version of Berkshelf? [\#1440](https://github.com/berkshelf/berkshelf/issues/1440)
- Documentation updates [\#1413](https://github.com/berkshelf/berkshelf/issues/1413)
- Cookbooks with same name but different paths in different groups cannot be resolved. [\#1401](https://github.com/berkshelf/berkshelf/issues/1401)
- Solution for lack of NO\_PROXY support - feedback requested [\#1341](https://github.com/berkshelf/berkshelf/issues/1341)

**Merged pull requests:**

- Removes the gzip middleware from Faraday builder. [\#1444](https://github.com/berkshelf/berkshelf/pull/1444) ([johnbellone](https://github.com/johnbellone))

## [v3.3.0](https://github.com/berkshelf/berkshelf/tree/v3.3.0) (2015-06-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.4...v3.3.0)

**Fixed bugs:**

- `berks package` omitting all files except metadata.json on OS X Yosemite [\#1435](https://github.com/berkshelf/berkshelf/issues/1435)

**Closed issues:**

- "berks install" fetches from incorrect git source [\#1438](https://github.com/berkshelf/berkshelf/issues/1438)
- Berks upload against a local chef-zero instance is rediculously slow \(30 mins or more\) [\#1431](https://github.com/berkshelf/berkshelf/issues/1431)
- Feature request: ability to specify multiple Berksfiles [\#1430](https://github.com/berkshelf/berkshelf/issues/1430)
- berks vendor fails with dependent Berksfile [\#1428](https://github.com/berkshelf/berkshelf/issues/1428)
- Berkshelf should not require $HOME to be set [\#1427](https://github.com/berkshelf/berkshelf/issues/1427)
- Private BitBucket repository [\#1426](https://github.com/berkshelf/berkshelf/issues/1426)
- Berkshelf upload fails  [\#1424](https://github.com/berkshelf/berkshelf/issues/1424)

**Merged pull requests:**

- tiny docfixes [\#1434](https://github.com/berkshelf/berkshelf/pull/1434) ([dastergon](https://github.com/dastergon))
- Improved error msg for unknown compression types. [\#1433](https://github.com/berkshelf/berkshelf/pull/1433) ([patcon](https://github.com/patcon))
- Use httpclient instead of nethttp [\#1393](https://github.com/berkshelf/berkshelf/pull/1393) ([jf647](https://github.com/jf647))

## [v3.2.4](https://github.com/berkshelf/berkshelf/tree/v3.2.4) (2015-04-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.3...v3.2.4)

**Closed issues:**

- Why does berkshelf tries to use deleted cookbook? [\#1421](https://github.com/berkshelf/berkshelf/issues/1421)
- Question about dependency resolver [\#1416](https://github.com/berkshelf/berkshelf/issues/1416)
- Weird version resolved for apache2 cookbook [\#1415](https://github.com/berkshelf/berkshelf/issues/1415)
- Support for multiple files [\#1411](https://github.com/berkshelf/berkshelf/issues/1411)
- berks upload fails with "Invalid value '~\> 0' for metadata.dependencies" [\#1409](https://github.com/berkshelf/berkshelf/issues/1409)
- Leverage non-supermarket dependencies' Berksfiles [\#1408](https://github.com/berkshelf/berkshelf/issues/1408)
- cookbook gets uploaded with half name [\#1407](https://github.com/berkshelf/berkshelf/issues/1407)
- Version metadata issue when using Berkshelf [\#1406](https://github.com/berkshelf/berkshelf/issues/1406)
- Long delay at "Resolving cookbook dependencies with Berkshelf 3.2.3..." during a "kitchen converge" [\#1403](https://github.com/berkshelf/berkshelf/issues/1403)
- Allow include support within Berksfile [\#1397](https://github.com/berkshelf/berkshelf/issues/1397)
- \[gh-pages\] Vagrant+Berkshelf plugin version is not supported [\#1396](https://github.com/berkshelf/berkshelf/issues/1396)
- Can't disable SSL verification [\#1390](https://github.com/berkshelf/berkshelf/issues/1390)
- Two cookbooks with different versions of the same dependency [\#1389](https://github.com/berkshelf/berkshelf/issues/1389)
- Can't package cookbooks on Windows host using test-kitchen [\#1388](https://github.com/berkshelf/berkshelf/issues/1388)
- berks install --without solo [\#1387](https://github.com/berkshelf/berkshelf/issues/1387)
- multiple depends lines for same cookbook? [\#1386](https://github.com/berkshelf/berkshelf/issues/1386)
- How to skip strict dependency check while running 'berks install' [\#1385](https://github.com/berkshelf/berkshelf/issues/1385)
- berks install error - data too large for key size \(OpenSSL::PKey::RSAError\) [\#1384](https://github.com/berkshelf/berkshelf/issues/1384)
- issue using "berks upload" [\#1383](https://github.com/berkshelf/berkshelf/issues/1383)
- "berks upload" Leaving out a File [\#1382](https://github.com/berkshelf/berkshelf/issues/1382)
- Dependancy resolution fails when using github: in cookbooks brought in via path: [\#1379](https://github.com/berkshelf/berkshelf/issues/1379)
- berks upload resolving wrong client\_key path from knife.rb [\#1376](https://github.com/berkshelf/berkshelf/issues/1376)
- Where to begin ... [\#1371](https://github.com/berkshelf/berkshelf/issues/1371)
- Getting undefined method `retryable' on new v3.2.3 [\#1370](https://github.com/berkshelf/berkshelf/issues/1370)
- Bump required Retryable gem version [\#1368](https://github.com/berkshelf/berkshelf/issues/1368)
- SLv3 read server certificate B: certificate verify failed \(Faraday::SSLError\) [\#1360](https://github.com/berkshelf/berkshelf/issues/1360)

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

**Fixed bugs:**

- Recipe metadata.rb is removed [\#1344](https://github.com/berkshelf/berkshelf/issues/1344)

**Closed issues:**

- Unable to resolve dependencies: berkshelf requires retryable \(~\> 1.3.3\); ridley requires retryable \(\>= 2.0.0\) [\#1369](https://github.com/berkshelf/berkshelf/issues/1369)
- Berkshelf fails to parse metadata.rb when referencing cookbook from local directory / git / github [\#1366](https://github.com/berkshelf/berkshelf/issues/1366)
- Local cache and decomissioning version of cookbook in supermarket [\#1361](https://github.com/berkshelf/berkshelf/issues/1361)

**Merged pull requests:**

- super minor typo fix [\#1367](https://github.com/berkshelf/berkshelf/pull/1367) ([dpetzel](https://github.com/dpetzel))
- Correct help command [\#1365](https://github.com/berkshelf/berkshelf/pull/1365) ([gsf](https://github.com/gsf))
- Fix e.message to show detailed error messages [\#1364](https://github.com/berkshelf/berkshelf/pull/1364) ([sonots](https://github.com/sonots))
- add ConfigurationError [\#1363](https://github.com/berkshelf/berkshelf/pull/1363) ([sonots](https://github.com/sonots))
- Fixed README description of config file search [\#1359](https://github.com/berkshelf/berkshelf/pull/1359) ([BackSlasher](https://github.com/BackSlasher))

## [v3.2.2](https://github.com/berkshelf/berkshelf/tree/v3.2.2) (2014-12-18)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.1...v3.2.2)

**Closed issues:**

- Git option in Berksfile is ignored [\#1355](https://github.com/berkshelf/berkshelf/issues/1355)
- source "https://supermarket.getchef.com" should be updated to chef.io domain [\#1349](https://github.com/berkshelf/berkshelf/issues/1349)
- Error disabling SSL [\#1144](https://github.com/berkshelf/berkshelf/issues/1144)

**Merged pull requests:**

- Only exclude top-level metadata.rb file while vendoring [\#1353](https://github.com/berkshelf/berkshelf/pull/1353) ([jpruetting](https://github.com/jpruetting))
- Use chef.io [\#1351](https://github.com/berkshelf/berkshelf/pull/1351) ([sethvargo](https://github.com/sethvargo))
- Use chef.io [\#1350](https://github.com/berkshelf/berkshelf/pull/1350) ([sethvargo](https://github.com/sethvargo))
- Fix edge cases with vendoring [\#1342](https://github.com/berkshelf/berkshelf/pull/1342) ([rchekaluk](https://github.com/rchekaluk))

## [v3.2.1](https://github.com/berkshelf/berkshelf/tree/v3.2.1) (2014-11-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.2.0...v3.2.1)

**Fixed bugs:**

- `berks vendor` puts all files in a single directory [\#1336](https://github.com/berkshelf/berkshelf/issues/1336)
- `berks upload` and `berks install` does not clean up temp directories and files [\#1333](https://github.com/berkshelf/berkshelf/issues/1333)
- berkshelf 3.1.1 is not uploading files from cookbook files directory [\#1191](https://github.com/berkshelf/berkshelf/issues/1191)

**Closed issues:**

- berks vendor does not exclude "metadata.rb" from destination dir [\#1338](https://github.com/berkshelf/berkshelf/issues/1338)
- \[test\] The tests shouldn't overwrite ~/.berkshelf/config.json [\#1227](https://github.com/berkshelf/berkshelf/issues/1227)
- \[test\] The spec for cookbook\_generator doesn't work with local ~/.chef/knife.rb file. [\#1226](https://github.com/berkshelf/berkshelf/issues/1226)

**Merged pull requests:**

- Correct exclusion of metadata.rb [\#1339](https://github.com/berkshelf/berkshelf/pull/1339) ([rveznaver](https://github.com/rveznaver))
- fix chefignore for files in sub directories [\#1335](https://github.com/berkshelf/berkshelf/pull/1335) ([triccardi-systran](https://github.com/triccardi-systran))
- Do not leak tempdirs [\#1334](https://github.com/berkshelf/berkshelf/pull/1334) ([sethvargo](https://github.com/sethvargo))

## [v3.2.0](https://github.com/berkshelf/berkshelf/tree/v3.2.0) (2014-10-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.5...v3.2.0)

**Implemented enhancements:**

- Update Vendor Directories without Top-Level Directory Removal [\#1275](https://github.com/berkshelf/berkshelf/issues/1275)
- Generate a lock file with the same name of the original Berksfile [\#1247](https://github.com/berkshelf/berkshelf/issues/1247)

**Fixed bugs:**

- Can't add a github cookbook - Failed to complete \#converge action: \[Berkshelf::NotACookbook\] [\#1311](https://github.com/berkshelf/berkshelf/issues/1311)
- BERKSHELF\_PATH must be an absolute path to checkout git-based Cookbooks [\#1256](https://github.com/berkshelf/berkshelf/issues/1256)
- timeout.rb:57:in `start': can't create Thread \(11\) \(ThreadError\) [\#1224](https://github.com/berkshelf/berkshelf/issues/1224)
- Package task reports unhelpful Ridley::Errors::MissingNameAttribute error message [\#1197](https://github.com/berkshelf/berkshelf/issues/1197)
- berks upload fails with "Invalid element in array value of 'files'." [\#706](https://github.com/berkshelf/berkshelf/issues/706)

**Closed issues:**

- Single quotes in berks viz will break windows clients [\#1323](https://github.com/berkshelf/berkshelf/issues/1323)
- Feature - viz with versions [\#1320](https://github.com/berkshelf/berkshelf/issues/1320)
- Can't fetch cookbook [\#1319](https://github.com/berkshelf/berkshelf/issues/1319)
- Can't vendor to existing directory [\#1315](https://github.com/berkshelf/berkshelf/issues/1315)
- Berks chooses supermarket over git [\#1310](https://github.com/berkshelf/berkshelf/issues/1310)
- berks upload fails with delete permission denied on metadata.json [\#1308](https://github.com/berkshelf/berkshelf/issues/1308)
- berks upload fails when berkshelf path has a space in it [\#1307](https://github.com/berkshelf/berkshelf/issues/1307)
- Support of multiple cookbook with same name [\#1306](https://github.com/berkshelf/berkshelf/issues/1306)
- Pre-release versions cause upload to fail [\#1305](https://github.com/berkshelf/berkshelf/issues/1305)
- Multiple sources causes Berkshelf to hang [\#1304](https://github.com/berkshelf/berkshelf/issues/1304)
- berkshelf / lib / berkshelf / locations / git.rb : 62 \[The issues with unstaged changes on case insensitive file system\) [\#1302](https://github.com/berkshelf/berkshelf/issues/1302)
- Bump Celluloid dependency to 0.16.0 \(not pre\) [\#1300](https://github.com/berkshelf/berkshelf/issues/1300)
- berks continues to show version 2.0.18 [\#1299](https://github.com/berkshelf/berkshelf/issues/1299)
- RuntimeError: Couldn't determine Berks version [\#1298](https://github.com/berkshelf/berkshelf/issues/1298)
- "Missing Cookbooks: No such cookbook: apt" when using depends in metadata.rb [\#1297](https://github.com/berkshelf/berkshelf/issues/1297)
- Berkshelf::Packager fails when in used in multithreading env [\#1296](https://github.com/berkshelf/berkshelf/issues/1296)
- Tag names with duplicate \#'s on the end are truncated in Berksfile.lock [\#1295](https://github.com/berkshelf/berkshelf/issues/1295)
- berks install failing on due to file compression error [\#1292](https://github.com/berkshelf/berkshelf/issues/1292)
- presumably berks should exit with 127 rather than 0 when no such subcomand [\#1288](https://github.com/berkshelf/berkshelf/issues/1288)
- \[Berkshelf::APIClient::TimeoutError\] Unable to connect to: https://supermarket.getchef.com [\#1287](https://github.com/berkshelf/berkshelf/issues/1287)
- I wrote a cookbook that can't be included in other cookbooks [\#1284](https://github.com/berkshelf/berkshelf/issues/1284)
- set cookbook sources in user/site configuration, not Berksfile [\#1281](https://github.com/berkshelf/berkshelf/issues/1281)
- Error installing berkshelf on FreeBSD 10.0-RELEASE [\#1280](https://github.com/berkshelf/berkshelf/issues/1280)
- Support Vagrant's rsync method for loading code into the VM [\#1278](https://github.com/berkshelf/berkshelf/issues/1278)
- Why Use Static String in Metadata.rb generated files? [\#1277](https://github.com/berkshelf/berkshelf/issues/1277)
- Lockout dependency gem versions  [\#1276](https://github.com/berkshelf/berkshelf/issues/1276)
- Redirect Errors [\#1269](https://github.com/berkshelf/berkshelf/issues/1269)
- berks install fails with JSON error [\#1267](https://github.com/berkshelf/berkshelf/issues/1267)
- Expose berkshelf-api-client timeout features [\#1262](https://github.com/berkshelf/berkshelf/issues/1262)
- Default Vagrantfile requires vagrant-omnibus plugin [\#1244](https://github.com/berkshelf/berkshelf/issues/1244)
- Berks 3.1.2 - Ridley::Errors::SandboxCommitError: [\#1223](https://github.com/berkshelf/berkshelf/issues/1223)
- Hashie gem needs to be \< v3.0 [\#1218](https://github.com/berkshelf/berkshelf/issues/1218)
- berks throws in celluloid [\#1171](https://github.com/berkshelf/berkshelf/issues/1171)
- Failed to build gem native extension [\#1134](https://github.com/berkshelf/berkshelf/issues/1134)
- Respect transitive dependencies on git branches over community site [\#1126](https://github.com/berkshelf/berkshelf/issues/1126)
- Berks upload resulting in ECONNRESET [\#1067](https://github.com/berkshelf/berkshelf/issues/1067)

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

**Implemented enhancements:**

- Add Super Market location\_type support [\#1238](https://github.com/berkshelf/berkshelf/pull/1238) ([reset](https://github.com/reset))

**Fixed bugs:**

- berks cookbook generator uninitialized constant Berkshelf::CookbookGenerator::LICENSES [\#1268](https://github.com/berkshelf/berkshelf/pull/1268) ([dasibre](https://github.com/dasibre))

**Closed issues:**

- Configurational issue [\#1272](https://github.com/berkshelf/berkshelf/issues/1272)
- Crashing when contraints doesn't mean [\#1263](https://github.com/berkshelf/berkshelf/issues/1263)
- bundle problems with 3.1.4 [\#1261](https://github.com/berkshelf/berkshelf/issues/1261)

## [v3.1.4](https://github.com/berkshelf/berkshelf/tree/v3.1.4) (2014-07-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.18...v3.1.4)

**Fixed bugs:**

- Berkshelf can't checkout Git Cookbooks to a custom BERKSHELF\_PATH [\#1255](https://github.com/berkshelf/berkshelf/issues/1255)

**Closed issues:**

- 301 from community \(supermarket\) stop some cookbooks installing [\#1257](https://github.com/berkshelf/berkshelf/issues/1257)
- Faraday::SSLError: SSL\_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed [\#1254](https://github.com/berkshelf/berkshelf/issues/1254)
- berks package/vendor converts metadata.rb to metadata.json [\#1253](https://github.com/berkshelf/berkshelf/issues/1253)
- Redirection forbidden by open-uri.  [\#1252](https://github.com/berkshelf/berkshelf/issues/1252)

**Merged pull requests:**

- Version bump v3.1.4 [\#1260](https://github.com/berkshelf/berkshelf/pull/1260) ([sethvargo](https://github.com/sethvargo))
- Replace api.berkshelf.com with supermarket.getchef.com [\#1259](https://github.com/berkshelf/berkshelf/pull/1259) ([Maks3w](https://github.com/Maks3w))
- Follow redirects when we try to get a cookbook [\#1258](https://github.com/berkshelf/berkshelf/pull/1258) ([jujugrrr](https://github.com/jujugrrr))
- update all api.berkshelf.com references to supermarket.getchef.com [\#1250](https://github.com/berkshelf/berkshelf/pull/1250) ([reset](https://github.com/reset))

## [v2.0.18](https://github.com/berkshelf/berkshelf/tree/v2.0.18) (2014-07-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.17...v2.0.18)

**Fixed bugs:**

- berks upload fail [\#1241](https://github.com/berkshelf/berkshelf/issues/1241)
- NoMethodError: undefined method `cookbook' for nil:NilClass [\#1221](https://github.com/berkshelf/berkshelf/issues/1221)

**Closed issues:**

- allow parallel fetching of cookbooks [\#1249](https://github.com/berkshelf/berkshelf/issues/1249)
- Unable to satisfy constrains on package jenkins... [\#1248](https://github.com/berkshelf/berkshelf/issues/1248)
- dhcp private\_network in default Vagrantfile hits Vagrant/VirtualBox bug [\#1246](https://github.com/berkshelf/berkshelf/issues/1246)
- bundle install Gemfile ~\> 2.0 does not install 2.0.17 [\#1245](https://github.com/berkshelf/berkshelf/issues/1245)
- Pessimistic version locking on thor [\#1242](https://github.com/berkshelf/berkshelf/issues/1242)
- Issue updating berkshelf gem [\#1239](https://github.com/berkshelf/berkshelf/issues/1239)
- Berkshelf 3 - Kitchen: Message: SSL\_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed [\#1237](https://github.com/berkshelf/berkshelf/issues/1237)
- Berkshelf3 - Berkshelf::MismatchedCookbookName - unable to provision box [\#1236](https://github.com/berkshelf/berkshelf/issues/1236)
- berks install broken \(v2.0.\*\) [\#1235](https://github.com/berkshelf/berkshelf/issues/1235)
- Library not loaded. Reason: image not found [\#1234](https://github.com/berkshelf/berkshelf/issues/1234)
- Race Condition in feature tests [\#1233](https://github.com/berkshelf/berkshelf/issues/1233)
- undefined local variable or method `user' [\#1232](https://github.com/berkshelf/berkshelf/issues/1232)
- Misleading error message when a cookbook version is not found [\#1228](https://github.com/berkshelf/berkshelf/issues/1228)
- bundler & Chef-DK [\#1220](https://github.com/berkshelf/berkshelf/issues/1220)

**Merged pull requests:**

- Follow redirects [\#1251](https://github.com/berkshelf/berkshelf/pull/1251) ([sethvargo](https://github.com/sethvargo))
- Updated default vagrant box to Ubuntu 14.04 from Vagrant Cloud [\#1217](https://github.com/berkshelf/berkshelf/pull/1217) ([jossy](https://github.com/jossy))

## [v2.0.17](https://github.com/berkshelf/berkshelf/tree/v2.0.17) (2014-06-10)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.3...v2.0.17)

**Closed issues:**

- remove pre-release versioned dependencies [\#1230](https://github.com/berkshelf/berkshelf/issues/1230)
- Segmentation Fault using Berkshelf 3 w/ accidental homebrew gcc installed [\#1229](https://github.com/berkshelf/berkshelf/issues/1229)
- "package" with data bags [\#1222](https://github.com/berkshelf/berkshelf/issues/1222)

**Merged pull requests:**

- Lockdown Hashie \(2.0\) [\#1231](https://github.com/berkshelf/berkshelf/pull/1231) ([sethvargo](https://github.com/sethvargo))

## [v3.1.3](https://github.com/berkshelf/berkshelf/tree/v3.1.3) (2014-06-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.2...v3.1.3)

**Fixed bugs:**

- config.json in directory not respected [\#1214](https://github.com/berkshelf/berkshelf/issues/1214)
- Not having git in PATH environment variable in Windows gives error on running berks cookbook: No such file or directory - git init [\#1208](https://github.com/berkshelf/berkshelf/issues/1208)
- Berkshelf not resolving from correct source [\#1199](https://github.com/berkshelf/berkshelf/issues/1199)

**Closed issues:**

- Latest versions of Berkshelf are uninstallable due to Gecode [\#1212](https://github.com/berkshelf/berkshelf/issues/1212)
- `rescue in initialize': undefined local variable or method ` STDOUT' for \#\<Buff::Config::Ruby::Evaluator:0x00000101b23d18\> \(Buff::Errors::InvalidConfig\) [\#1207](https://github.com/berkshelf/berkshelf/issues/1207)
- 'berks apply' overwrites cookbook\_versions completely [\#1206](https://github.com/berkshelf/berkshelf/issues/1206)
- berks apply to local environment file [\#1205](https://github.com/berkshelf/berkshelf/issues/1205)
- Berks 2 on windows using tons of RAM and threads [\#1203](https://github.com/berkshelf/berkshelf/issues/1203)
- Upload skips dependencies? [\#1202](https://github.com/berkshelf/berkshelf/issues/1202)
- Does berkshelf support snapshot version from chef server? [\#1196](https://github.com/berkshelf/berkshelf/issues/1196)
- Multiple versions of cookbooks across environments [\#1167](https://github.com/berkshelf/berkshelf/issues/1167)
- development workflow with multiple cookbooks [\#1164](https://github.com/berkshelf/berkshelf/issues/1164)

**Merged pull requests:**

- bump ridley and buff dependencies [\#1219](https://github.com/berkshelf/berkshelf/pull/1219) ([reset](https://github.com/reset))
- Fixed a minor typo on the home page [\#1213](https://github.com/berkshelf/berkshelf/pull/1213) ([elektronaut](https://github.com/elektronaut))
- Extract git mixin into its own module [\#1209](https://github.com/berkshelf/berkshelf/pull/1209) ([sethvargo](https://github.com/sethvargo))
- ssl.verify option is ignored [\#1204](https://github.com/berkshelf/berkshelf/pull/1204) ([ohtake](https://github.com/ohtake))
- Fix windows specs [\#1200](https://github.com/berkshelf/berkshelf/pull/1200) ([danielsdeleo](https://github.com/danielsdeleo))
- Skip cached cookbooks missing their name attributes instead of failing [\#1198](https://github.com/berkshelf/berkshelf/pull/1198) ([KAllan357](https://github.com/KAllan357))

## [v3.1.2](https://github.com/berkshelf/berkshelf/tree/v3.1.2) (2014-05-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.16...v3.1.2)

**Fixed bugs:**

- Possible Race Condition in Feature test [\#1185](https://github.com/berkshelf/berkshelf/issues/1185)
- `berks install` using git-sourced cookbook fails when there is no master branch [\#1148](https://github.com/berkshelf/berkshelf/issues/1148)
- Fix Berkshelf::Graph\#update [\#1182](https://github.com/berkshelf/berkshelf/pull/1182) ([mjcdiggity](https://github.com/mjcdiggity))

**Closed issues:**

- Remove GithubLocation in favor of GitLocation [\#1193](https://github.com/berkshelf/berkshelf/issues/1193)
- Strange conflict [\#1190](https://github.com/berkshelf/berkshelf/issues/1190)
- Berkshelf 3.1.1 breaks test-kitchen vagrant chef-zero workflow [\#1189](https://github.com/berkshelf/berkshelf/issues/1189)
- Has anyone successfully installed Berkshelf on Windows? [\#1184](https://github.com/berkshelf/berkshelf/issues/1184)
- Berkshelf::BerksfileReadError [\#1181](https://github.com/berkshelf/berkshelf/issues/1181)
- set buff-config dependency to '~\> 0.4' [\#1179](https://github.com/berkshelf/berkshelf/issues/1179)
- UI is broken on windows on master [\#1176](https://github.com/berkshelf/berkshelf/issues/1176)
- \[Berkshelf::OutdatedDependency\] improving error message [\#1175](https://github.com/berkshelf/berkshelf/issues/1175)
- Nested git sourced cookbooks fail to install [\#1174](https://github.com/berkshelf/berkshelf/issues/1174)
- Berkshelf depends on pre-release gems [\#1172](https://github.com/berkshelf/berkshelf/issues/1172)
- installing gem dep-selector-libgecode takes forever [\#1166](https://github.com/berkshelf/berkshelf/issues/1166)
- stack level too deep with medium-sized Berksfile. [\#1160](https://github.com/berkshelf/berkshelf/issues/1160)
- stack level too deep \(SystemStackError\) [\#1159](https://github.com/berkshelf/berkshelf/issues/1159)
- Berksfile.lock versions \*still\* not followed [\#1158](https://github.com/berkshelf/berkshelf/issues/1158)
- Unable to fetch private repos \(v3.1.1\) [\#1157](https://github.com/berkshelf/berkshelf/issues/1157)
- "berks install" formatting is all screwed up [\#1156](https://github.com/berkshelf/berkshelf/issues/1156)
- An error occurred while reading the Berksfile: uninitialized constant Solve::Version [\#1155](https://github.com/berkshelf/berkshelf/issues/1155)
- Berks 3.1.1 throws  stack level too deep \(SystemStackError\) error [\#1154](https://github.com/berkshelf/berkshelf/issues/1154)
- The `berks outdated` command doesn't honor location info in the Berksfile [\#1153](https://github.com/berkshelf/berkshelf/issues/1153)
- Another "Unable to find a solution for demands with mercurial sources" [\#1152](https://github.com/berkshelf/berkshelf/issues/1152)
- berkshelf 3 not honoring protocol for github locations [\#1151](https://github.com/berkshelf/berkshelf/issues/1151)
- How do I generate a Berkshelf config.json file with Berkshelf 3.0? [\#1150](https://github.com/berkshelf/berkshelf/issues/1150)
- Specifying latest version of cookbook produces error [\#1149](https://github.com/berkshelf/berkshelf/issues/1149)
- Bundle CA certs [\#1030](https://github.com/berkshelf/berkshelf/issues/1030)
- Warn when declaring duplicate dependencies in metadata and Berksfile [\#526](https://github.com/berkshelf/berkshelf/issues/526)

**Merged pull requests:**

- Remove the .git directory for git-sourced cookbooks [\#1194](https://github.com/berkshelf/berkshelf/pull/1194) ([cnunciato](https://github.com/cnunciato))
- Apply environment file artifact [\#1188](https://github.com/berkshelf/berkshelf/pull/1188) ([stephenlauck](https://github.com/stephenlauck))
- Fix typo in show cmd description [\#1187](https://github.com/berkshelf/berkshelf/pull/1187) ([dougireton](https://github.com/dougireton))
- Do not care about ordered output during installation [\#1186](https://github.com/berkshelf/berkshelf/pull/1186) ([sethvargo](https://github.com/sethvargo))
- Update README.md.erb [\#1183](https://github.com/berkshelf/berkshelf/pull/1183) ([mjuszczak](https://github.com/mjuszczak))
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

**Closed issues:**

- Really need to put /opt/chefdk/embedded/bin in $PATH? [\#1147](https://github.com/berkshelf/berkshelf/issues/1147)
- berks configure depreciated? [\#1145](https://github.com/berkshelf/berkshelf/issues/1145)
- Berkshelf does not use the latest versions [\#1140](https://github.com/berkshelf/berkshelf/issues/1140)

**Merged pull requests:**

- Berkshelf 2.0.15 won't install with Vagrant 1.5.3 [\#1146](https://github.com/berkshelf/berkshelf/pull/1146) ([gaffneyc](https://github.com/gaffneyc))

## [v3.1.1](https://github.com/berkshelf/berkshelf/tree/v3.1.1) (2014-04-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.1.0...v3.1.1)

**Implemented enhancements:**

- Configurable templates [\#499](https://github.com/berkshelf/berkshelf/issues/499)

**Fixed bugs:**

- berks outdated is incorrect [\#1141](https://github.com/berkshelf/berkshelf/issues/1141)

**Closed issues:**

- berks upload fails after upgrading to chef-dk [\#1135](https://github.com/berkshelf/berkshelf/issues/1135)
- `berks upload` incorrectly updates Berksfile.lock, resulting in old version usage by vagrant [\#1054](https://github.com/berkshelf/berkshelf/issues/1054)

**Merged pull requests:**

- Bump required Ridley version to 3.1 [\#1143](https://github.com/berkshelf/berkshelf/pull/1143) ([sethvargo](https://github.com/sethvargo))
- Fix outdated checks [\#1142](https://github.com/berkshelf/berkshelf/pull/1142) ([sethvargo](https://github.com/sethvargo))

## [v3.1.0](https://github.com/berkshelf/berkshelf/tree/v3.1.0) (2014-04-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.1...v3.1.0)

**Implemented enhancements:**

- add 'berks tree' command [\#607](https://github.com/berkshelf/berkshelf/issues/607)

**Closed issues:**

- Error uploading to chef server  [\#1139](https://github.com/berkshelf/berkshelf/issues/1139)
- "gem install berkshelf" fails with Ruby 2.1.1 - "Failed to build gecode library" [\#1138](https://github.com/berkshelf/berkshelf/issues/1138)
- Official Ruby 2.1 Support [\#1131](https://github.com/berkshelf/berkshelf/issues/1131)
- Depsolver needs better error messages when missing a cookbook dependency [\#1130](https://github.com/berkshelf/berkshelf/issues/1130)

**Merged pull requests:**

- Add `berks viz` [\#1137](https://github.com/berkshelf/berkshelf/pull/1137) ([sethvargo](https://github.com/sethvargo))
- minimum viable depsolving exception handling fix [\#1136](https://github.com/berkshelf/berkshelf/pull/1136) ([lamont-granquist](https://github.com/lamont-granquist))
- Typo and edit to index page of docs [\#1133](https://github.com/berkshelf/berkshelf/pull/1133) ([nicgrayson](https://github.com/nicgrayson))
- Change `berks show` to output the path to a cookbook on disk [\#1053](https://github.com/berkshelf/berkshelf/pull/1053) ([sethvargo](https://github.com/sethvargo))

## [v3.0.1](https://github.com/berkshelf/berkshelf/tree/v3.0.1) (2014-04-15)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0...v3.0.1)

**Closed issues:**

- berks install still failing [\#1125](https://github.com/berkshelf/berkshelf/issues/1125)

**Merged pull requests:**

- Celluloid worker pool requires at least 2 cores [\#1129](https://github.com/berkshelf/berkshelf/pull/1129) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0](https://github.com/berkshelf/berkshelf/tree/v3.0.0) (2014-04-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.15...v3.0.0)

**Closed issues:**

- solve 1.1.0, released today, breaks berkshelf 2.0.14 [\#1128](https://github.com/berkshelf/berkshelf/issues/1128)
- Documentation for Berkshelf 3.0 [\#822](https://github.com/berkshelf/berkshelf/issues/822)

**Merged pull requests:**

- use celluloid for threaded cookbook downloads [\#1127](https://github.com/berkshelf/berkshelf/pull/1127) ([reset](https://github.com/reset))

## [v2.0.15](https://github.com/berkshelf/berkshelf/tree/v2.0.15) (2014-04-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.rc1...v2.0.15)

**Fixed bugs:**

- Friendly error message when path location does not exist or contain a cookbook [\#1119](https://github.com/berkshelf/berkshelf/issues/1119)
- berks install failing [\#1116](https://github.com/berkshelf/berkshelf/issues/1116)
- `berks vendor` "cannot be trusted!" error [\#1124](https://github.com/berkshelf/berkshelf/pull/1124) ([JeanMertz](https://github.com/JeanMertz))

**Closed issues:**

- dep\_gecode.so undefined symbol: \_ZN6Gecode16ValBranchOptions3defE \(LoadError\) [\#1121](https://github.com/berkshelf/berkshelf/issues/1121)

**Merged pull requests:**

- Fix community cookbook download error  [\#1123](https://github.com/berkshelf/berkshelf/pull/1123) ([mjcdiggity](https://github.com/mjcdiggity))
- Remove gecode install instructions from README [\#1122](https://github.com/berkshelf/berkshelf/pull/1122) ([danielsdeleo](https://github.com/danielsdeleo))

## [v3.0.0.rc1](https://github.com/berkshelf/berkshelf/tree/v3.0.0.rc1) (2014-04-09)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta9...v3.0.0.rc1)

**Implemented enhancements:**

- Loosen constraint on Thor [\#1107](https://github.com/berkshelf/berkshelf/pull/1107) ([reset](https://github.com/reset))
- Add `--type` flag to `berks cookbook` command [\#955](https://github.com/berkshelf/berkshelf/pull/955) ([reset](https://github.com/reset))

**Fixed bugs:**

- Upload not uploading all transitive dependencies [\#1113](https://github.com/berkshelf/berkshelf/issues/1113)
- berks upload \<cookbook\> uploading all cookbooks [\#1097](https://github.com/berkshelf/berkshelf/issues/1097)
- `berks install` does not correctly update dependency when switching from remote to local cookbook [\#1061](https://github.com/berkshelf/berkshelf/issues/1061)
- A cookbook which is a dependency should be a valid argument for `berks update` [\#1005](https://github.com/berkshelf/berkshelf/issues/1005)

**Closed issues:**

- berks upload does not recognize second-level nested cookbooks [\#1118](https://github.com/berkshelf/berkshelf/issues/1118)
- Issues with conflicting gem versions \(Thor, specifically\) [\#1109](https://github.com/berkshelf/berkshelf/issues/1109)
- dep\_selector install error [\#1108](https://github.com/berkshelf/berkshelf/issues/1108)

**Merged pull requests:**

- Force unlock elements in the graph when reducing [\#1117](https://github.com/berkshelf/berkshelf/pull/1117) ([sethvargo](https://github.com/sethvargo))
- Support transitive update [\#1115](https://github.com/berkshelf/berkshelf/pull/1115) ([sethvargo](https://github.com/sethvargo))
- Nope nope nope, nope, no. This is so fucking dangerous, no. [\#1114](https://github.com/berkshelf/berkshelf/pull/1114) ([reset](https://github.com/reset))
- Support uploading a single cookbook \(transitive dependency\) [\#1112](https://github.com/berkshelf/berkshelf/pull/1112) ([sethvargo](https://github.com/sethvargo))
- use system gecode when building [\#1111](https://github.com/berkshelf/berkshelf/pull/1111) ([reset](https://github.com/reset))
- Dump statuses in gitter [\#1110](https://github.com/berkshelf/berkshelf/pull/1110) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta9](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta9) (2014-04-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta8...v3.0.0.beta9)

**Closed issues:**

- Update Resolver to Gecode [\#1093](https://github.com/berkshelf/berkshelf/issues/1093)
- Updated Bleeding edge guide doesn't work [\#1079](https://github.com/berkshelf/berkshelf/issues/1079)

**Merged pull requests:**

- Update the API to use semverse [\#1106](https://github.com/berkshelf/berkshelf/pull/1106) ([sethvargo](https://github.com/sethvargo))
- BaseLOcation -\> BaseLocation [\#1105](https://github.com/berkshelf/berkshelf/pull/1105) ([EvanPurkhiser](https://github.com/EvanPurkhiser))
- Update API calls to Solve to match 1.0.0.dev [\#1104](https://github.com/berkshelf/berkshelf/pull/1104) ([reset](https://github.com/reset))
- update generator for Vagrant 1.5.x [\#1103](https://github.com/berkshelf/berkshelf/pull/1103) ([reset](https://github.com/reset))

## [v3.0.0.beta8](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta8) (2014-04-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta7...v3.0.0.beta8)

**Implemented enhancements:**

- Move SCM downloaded cookbooks to a different cookbook store [\#970](https://github.com/berkshelf/berkshelf/issues/970)
- Refactor away the GithubLocation class [\#873](https://github.com/berkshelf/berkshelf/issues/873)
- Redundant Downloads/caching with multiple :rel paths off a single repo [\#832](https://github.com/berkshelf/berkshelf/issues/832)
- Upload should be more verbose [\#780](https://github.com/berkshelf/berkshelf/issues/780)
- add `berks search` command [\#754](https://github.com/berkshelf/berkshelf/issues/754)
- Recurse into transitive dependencies when lockfile trusting [\#1058](https://github.com/berkshelf/berkshelf/pull/1058) ([sethvargo](https://github.com/sethvargo))
- Make formatters object-oriented so we can Autoload them [\#1020](https://github.com/berkshelf/berkshelf/pull/1020) ([sethvargo](https://github.com/sethvargo))

**Fixed bugs:**

- berks update will not fetch latest commit from git [\#1072](https://github.com/berkshelf/berkshelf/issues/1072)
- berks install used to update the current cookbook's version in the lockfile. [\#1063](https://github.com/berkshelf/berkshelf/issues/1063)
- Shit goes south when there's no metadata name [\#1052](https://github.com/berkshelf/berkshelf/issues/1052)
- berks install hangs trying to resolve conflicting dependencies instead of failing fast [\#1040](https://github.com/berkshelf/berkshelf/issues/1040)
- New lockfile doesn't interact well with --except [\#1037](https://github.com/berkshelf/berkshelf/issues/1037)
- beta7- Apparent hang when running berks install with github locations in Berksfile [\#1034](https://github.com/berkshelf/berkshelf/issues/1034)
- Vendor only outputting top level cookbooks [\#1025](https://github.com/berkshelf/berkshelf/issues/1025)
- `berks update` does not work correctly [\#993](https://github.com/berkshelf/berkshelf/issues/993)
- --exclude is ignored [\#972](https://github.com/berkshelf/berkshelf/issues/972)
- 3.0.0beta4 Errors parsing some knife.rb options. [\#965](https://github.com/berkshelf/berkshelf/issues/965)
- Unsolvable demands [\#959](https://github.com/berkshelf/berkshelf/issues/959)
- Detect if Berksfile.lock is writable and raise early if not [\#956](https://github.com/berkshelf/berkshelf/issues/956)
- Only/Except flags should honor lockfile [\#902](https://github.com/berkshelf/berkshelf/issues/902)
- --halt-on-frozen option overly strict [\#883](https://github.com/berkshelf/berkshelf/issues/883)
- Massive chefignore spam in debug output [\#820](https://github.com/berkshelf/berkshelf/issues/820)
- berks install doesn't seem to install something local [\#779](https://github.com/berkshelf/berkshelf/issues/779)
- Berks package not producing tarballs compatible with chef-solo [\#1099](https://github.com/berkshelf/berkshelf/pull/1099) ([pghalliday](https://github.com/pghalliday))
- Fix location delegation [\#1090](https://github.com/berkshelf/berkshelf/pull/1090) ([sethvargo](https://github.com/sethvargo))
- Suppress default location [\#1062](https://github.com/berkshelf/berkshelf/pull/1062) ([sethvargo](https://github.com/sethvargo))

**Closed issues:**

- bundle install cannot resolve project dependencies [\#1100](https://github.com/berkshelf/berkshelf/issues/1100)
- metadata.rb dep changes don't cause Berkshelf to properly recompute dependencies [\#1098](https://github.com/berkshelf/berkshelf/issues/1098)
- Bump Ridley [\#1095](https://github.com/berkshelf/berkshelf/issues/1095)
- berks update tries to respect Berksfile.lock [\#1091](https://github.com/berkshelf/berkshelf/issues/1091)
- Recent git cookbook caching broken with multi-cookbook repos. [\#1081](https://github.com/berkshelf/berkshelf/issues/1081)
- API requests hanging [\#1080](https://github.com/berkshelf/berkshelf/issues/1080)
- berkshelf 100% CPU consumed [\#1076](https://github.com/berkshelf/berkshelf/issues/1076)
- Have to delete Berksfile.lock every time I run `install` [\#1073](https://github.com/berkshelf/berkshelf/issues/1073)
- Unable to find a solution for demands \> berkshelf 3.0.0.beta5 [\#1071](https://github.com/berkshelf/berkshelf/issues/1071)
- Confusion with tmp directories [\#1069](https://github.com/berkshelf/berkshelf/issues/1069)
- berks install fails on the second execution. [\#1066](https://github.com/berkshelf/berkshelf/issues/1066)
- Backport \#778 to 2-0-stable [\#1060](https://github.com/berkshelf/berkshelf/issues/1060)
- Show what was uploaded [\#1059](https://github.com/berkshelf/berkshelf/issues/1059)
- Unable to access cookbooks from a private github instance [\#1057](https://github.com/berkshelf/berkshelf/issues/1057)
- Bleeding edge instructions likely won't work [\#1055](https://github.com/berkshelf/berkshelf/issues/1055)
- Cookbook not found due to underscore? [\#1050](https://github.com/berkshelf/berkshelf/issues/1050)
- Berks can't resolve deps of a cookbook that can be resolved by chef server [\#1047](https://github.com/berkshelf/berkshelf/issues/1047)
- Wiki: 2.x-to-3.0-Upgrade-Guide - source lacks protocol [\#1046](https://github.com/berkshelf/berkshelf/issues/1046)
- Unable to add dependencies via metadata after lockfile creation [\#1043](https://github.com/berkshelf/berkshelf/issues/1043)
- Report version not found instead of Cookbook not found [\#1041](https://github.com/berkshelf/berkshelf/issues/1041)
- firewall issues with 3.0.0.beta7 [\#1039](https://github.com/berkshelf/berkshelf/issues/1039)
- Resolver.resolve takes a very long time for a new installation with many cookbooks. [\#1038](https://github.com/berkshelf/berkshelf/issues/1038)
- Can not resolve a dependency cookbook's "git" cookbook dependency [\#1036](https://github.com/berkshelf/berkshelf/issues/1036)
- Silent upload fail of frozen cookbooks [\#1024](https://github.com/berkshelf/berkshelf/issues/1024)
- `copy': unknown file type when cloning librato/statsd-cookbook  [\#1015](https://github.com/berkshelf/berkshelf/issues/1015)
- "Can't convert Hash into String" when using "site: :opscode" location [\#1014](https://github.com/berkshelf/berkshelf/issues/1014)
- Error for missing transitive dependencies could be better. [\#1008](https://github.com/berkshelf/berkshelf/issues/1008)
- Better way to use Berkshelf 3 [\#981](https://github.com/berkshelf/berkshelf/issues/981)
- SSL errors with https://api.berkshelf.com/ [\#968](https://github.com/berkshelf/berkshelf/issues/968)
- Berkshelf is not honoring dependencies in metadata [\#952](https://github.com/berkshelf/berkshelf/issues/952)
- Fill out the deprecated-locations wiki page [\#936](https://github.com/berkshelf/berkshelf/issues/936)
- `berks upload` reports nonexistent cookbook is frozen [\#932](https://github.com/berkshelf/berkshelf/issues/932)
- Berkshelf 3 beta3 not uploading dependencies of Path-based cookbook [\#913](https://github.com/berkshelf/berkshelf/issues/913)
- Handle Bad Responses [\#912](https://github.com/berkshelf/berkshelf/issues/912)
- Library cookbook from Github [\#910](https://github.com/berkshelf/berkshelf/issues/910)
- Testing section of Contributing docs could use more detail [\#849](https://github.com/berkshelf/berkshelf/issues/849)
- Getting started with chef solo [\#819](https://github.com/berkshelf/berkshelf/issues/819)
- Make Installer idempotent or improve retrive\_locked [\#811](https://github.com/berkshelf/berkshelf/issues/811)
- Does "berks upload --skip-dependencies" no longer work? [\#773](https://github.com/berkshelf/berkshelf/issues/773)
- SSL issue when using vagrant's chef-client provisioner. [\#378](https://github.com/berkshelf/berkshelf/issues/378)

**Merged pull requests:**

- Update Ridley, Faraday, Berkshefl-API, Berkshefl-API-Client [\#1102](https://github.com/berkshelf/berkshelf/pull/1102) ([reset](https://github.com/reset))
- remove Berksfile and Berksfile.lock from generated chefignore file [\#1096](https://github.com/berkshelf/berkshelf/pull/1096) ([reset](https://github.com/reset))
- Add `berks search` command for searching remote sources [\#1092](https://github.com/berkshelf/berkshelf/pull/1092) ([sethvargo](https://github.com/sethvargo))
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

## [v3.0.0.beta7](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta7) (2014-02-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta6...v3.0.0.beta7)

**Implemented enhancements:**

- Github Enterprise Location Support [\#987](https://github.com/berkshelf/berkshelf/issues/987)
- Add private Github repository support to Downloader [\#958](https://github.com/berkshelf/berkshelf/issues/958)
- Berks outdated doesn't work [\#831](https://github.com/berkshelf/berkshelf/issues/831)
- First class Vagrant Chef-Zero support [\#810](https://github.com/berkshelf/berkshelf/issues/810)
- Refactor the lockfile to separate top-level dependencies from the graph [\#1009](https://github.com/berkshelf/berkshelf/pull/1009) ([sethvargo](https://github.com/sethvargo))
- Missing CHANGELOG.md [\#1007](https://github.com/berkshelf/berkshelf/pull/1007) ([jasnab](https://github.com/jasnab))
- Remove implicit default source [\#983](https://github.com/berkshelf/berkshelf/pull/983) ([borntyping](https://github.com/borntyping))

**Fixed bugs:**

- Incorrect error when there's no Internet [\#1018](https://github.com/berkshelf/berkshelf/issues/1018)
- Failure to parse metadata.rb can cause misleading error message to user [\#996](https://github.com/berkshelf/berkshelf/issues/996)
- Local cookbooks are ignored when selecting dependencies [\#898](https://github.com/berkshelf/berkshelf/issues/898)
- Berks upload throws Ridley::SandboxResource crashed! with local Chef11 [\#896](https://github.com/berkshelf/berkshelf/issues/896)
- berks vendor does not work if the path is nested [\#984](https://github.com/berkshelf/berkshelf/pull/984) ([rteabeault](https://github.com/rteabeault))

**Closed issues:**

- Delay freezing of cookbooks [\#1023](https://github.com/berkshelf/berkshelf/issues/1023)
- Unable to do a berks upload on ulimit dependency [\#1019](https://github.com/berkshelf/berkshelf/issues/1019)
- Encoding::InvalidByteSequenceError while running berks vendor [\#1016](https://github.com/berkshelf/berkshelf/issues/1016)
- Berkshelf 3.0 docs are invisible even though it's now the recommended version \(apparently\) [\#1012](https://github.com/berkshelf/berkshelf/issues/1012)
- Berkshelf ignores the locked versions of the current metadata.rb \(conflicts or depends\) [\#1010](https://github.com/berkshelf/berkshelf/issues/1010)
- Berkshelf crashes when running berks upload [\#985](https://github.com/berkshelf/berkshelf/issues/985)
- berks commands fail on OSX [\#927](https://github.com/berkshelf/berkshelf/issues/927)
- Don't fetch a new copy of the git repo each run [\#858](https://github.com/berkshelf/berkshelf/issues/858)
- Get timeout when uploading a largish cookbook [\#761](https://github.com/berkshelf/berkshelf/issues/761)

**Merged pull requests:**

- Add feature for vendoring transitive dependencies [\#1026](https://github.com/berkshelf/berkshelf/pull/1026) ([sethvargo](https://github.com/sethvargo))
- Update Vagrantfile.erb [\#1022](https://github.com/berkshelf/berkshelf/pull/1022) ([berniedurfee](https://github.com/berniedurfee))
- Don't load Octokit until we need it [\#1017](https://github.com/berkshelf/berkshelf/pull/1017) ([sethvargo](https://github.com/sethvargo))
- Raise on all commands when install is required but not performed [\#949](https://github.com/berkshelf/berkshelf/pull/949) ([reset](https://github.com/reset))

## [v3.0.0.beta6](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta6) (2014-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.14...v3.0.0.beta6)

**Fixed bugs:**

- berks upload fails with different berkshelf & ridley versions [\#890](https://github.com/berkshelf/berkshelf/issues/890)

## [v2.0.14](https://github.com/berkshelf/berkshelf/tree/v2.0.14) (2014-02-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta5...v2.0.14)

**Implemented enhancements:**

- Sane defaults for OSX and keep current dir [\#1000](https://github.com/berkshelf/berkshelf/pull/1000) ([mjallday](https://github.com/mjallday))

**Fixed bugs:**

- berks install/update not accurately resolving dependency [\#1001](https://github.com/berkshelf/berkshelf/issues/1001)
- All dependencies are not being written to Lockfile on clean install [\#978](https://github.com/berkshelf/berkshelf/issues/978)

**Closed issues:**

- Berkshelf not fetching dependencies recursively [\#1003](https://github.com/berkshelf/berkshelf/issues/1003)
- Generated config.json unformatted [\#1002](https://github.com/berkshelf/berkshelf/issues/1002)
- Berks 3.0.0.beta4 hits API site when given git tag for cookbook [\#999](https://github.com/berkshelf/berkshelf/issues/999)
- Berks upload freeze [\#998](https://github.com/berkshelf/berkshelf/issues/998)
- cookbook path dependencies need to be specified in wrapper-cookbook as well [\#995](https://github.com/berkshelf/berkshelf/issues/995)
- packager should skip .git [\#994](https://github.com/berkshelf/berkshelf/issues/994)

**Merged pull requests:**

- Update berksfile.rb [\#1006](https://github.com/berkshelf/berkshelf/pull/1006) ([erichelgeson](https://github.com/erichelgeson))
- Backport metadata.json detection logic to berks2 [\#1004](https://github.com/berkshelf/berkshelf/pull/1004) ([ivey](https://github.com/ivey))
- Issue 978 - Make sure to add dependencies to artifacts that are loaded from the cookbook store [\#997](https://github.com/berkshelf/berkshelf/pull/997) ([rteabeault](https://github.com/rteabeault))

## [v3.0.0.beta5](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta5) (2014-01-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.13...v3.0.0.beta5)

## [v2.0.13](https://github.com/berkshelf/berkshelf/tree/v2.0.13) (2014-01-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.12...v2.0.13)

**Closed issues:**

- Set chef-repo as default location [\#990](https://github.com/berkshelf/berkshelf/issues/990)
- Support Github Enterprise [\#986](https://github.com/berkshelf/berkshelf/issues/986)
- Incorrect branch name shown for cached Git locations [\#980](https://github.com/berkshelf/berkshelf/issues/980)

**Merged pull requests:**

- Fix extra whitespace when commented line is empty [\#989](https://github.com/berkshelf/berkshelf/pull/989) ([cpuguy83](https://github.com/cpuguy83))
- enable downloading from private github repos [\#982](https://github.com/berkshelf/berkshelf/pull/982) ([punkle](https://github.com/punkle))

## [v2.0.12](https://github.com/berkshelf/berkshelf/tree/v2.0.12) (2014-01-08)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.11...v2.0.12)

**Closed issues:**

- Berkshelf 2.0.11 gem breaks when using faraday 0.9.0.rc6 [\#979](https://github.com/berkshelf/berkshelf/issues/979)

## [v2.0.11](https://github.com/berkshelf/berkshelf/tree/v2.0.11) (2014-01-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta4...v2.0.11)

**Implemented enhancements:**

- Don't reach out to internet when not necessary \(Offline Mode\) [\#861](https://github.com/berkshelf/berkshelf/issues/861)

**Fixed bugs:**

- properly handle 'cannot connect' to api servers when building universe [\#918](https://github.com/berkshelf/berkshelf/issues/918)
- Cookbook dependency error on second invocation of berks install [\#916](https://github.com/berkshelf/berkshelf/issues/916)
- Berkshelf.lock file not respected [\#908](https://github.com/berkshelf/berkshelf/issues/908)
- --skip-dependencies not working when using  a git source [\#886](https://github.com/berkshelf/berkshelf/issues/886)
- Berkshelf 3 overrides custom cookbooks w/ "locked\_version" of community cookbooks. [\#963](https://github.com/berkshelf/berkshelf/pull/963) ([joestump](https://github.com/joestump))
- berksfile.lock not honored for transitive dependencies [\#939](https://github.com/berkshelf/berkshelf/pull/939) ([keiths-osc](https://github.com/keiths-osc))
- Looking for wrong version [\#907](https://github.com/berkshelf/berkshelf/pull/907) ([scalp42](https://github.com/scalp42))
- exception info swallowed when git protocol doesn't work [\#879](https://github.com/berkshelf/berkshelf/pull/879) ([cjerdonek](https://github.com/cjerdonek))
- `berks install --quiet` mutes error output [\#827](https://github.com/berkshelf/berkshelf/pull/827) ([torandu](https://github.com/torandu))

**Closed issues:**

- Confused about `berks apply` semantics [\#977](https://github.com/berkshelf/berkshelf/issues/977)
- Path version is not a requirement [\#975](https://github.com/berkshelf/berkshelf/issues/975)
- berks update doesn't support --path [\#973](https://github.com/berkshelf/berkshelf/issues/973)
- Berkshelf 3 can't resolve on Linux. Works fine locally on OS X. [\#969](https://github.com/berkshelf/berkshelf/issues/969)
- Berkshelf ignores metadata.rb name when installing a cookbook. [\#964](https://github.com/berkshelf/berkshelf/issues/964)
- Berkshelf 3 sometimes downloads incomplete cookbook files. [\#961](https://github.com/berkshelf/berkshelf/issues/961)
- `berks install --path` broken in 464142ed8d [\#953](https://github.com/berkshelf/berkshelf/issues/953)
- mercurial \(hg\) location support  [\#950](https://github.com/berkshelf/berkshelf/issues/950)
- berkshelf-3.0.0.beta4 Berkshelf::GitError  [\#946](https://github.com/berkshelf/berkshelf/issues/946)
- ‘berks package’ includes .git directory for git/github cookbooks [\#938](https://github.com/berkshelf/berkshelf/issues/938)
- berkshelf-3.0.0.beta4 undefined method `cookbook' for nil:NilClass [\#937](https://github.com/berkshelf/berkshelf/issues/937)
- feature request: 'berks apply' or 'berks update' to warn/halt on minor/major version increases [\#930](https://github.com/berkshelf/berkshelf/issues/930)
- Berkshelf 2.0.10 gem breaks when using faraday 0.9.0.rc5 [\#855](https://github.com/berkshelf/berkshelf/issues/855)
- Can berks install add the current cookbook to the shelf? [\#834](https://github.com/berkshelf/berkshelf/issues/834)
- `berks shelf SUBCOMMAND` not apparent what actions can be taken [\#805](https://github.com/berkshelf/berkshelf/issues/805)
- `berks init` should warn when there is no default recipe [\#606](https://github.com/berkshelf/berkshelf/issues/606)

**Merged pull requests:**

- Make sure path/scm location is used during dependency resolution [\#976](https://github.com/berkshelf/berkshelf/pull/976) ([grobie](https://github.com/grobie))
- Fix typo [\#974](https://github.com/berkshelf/berkshelf/pull/974) ([gregkare](https://github.com/gregkare))
- improve warnings when receiving APIClientErrors when building universe [\#971](https://github.com/berkshelf/berkshelf/pull/971) ([reset](https://github.com/reset))
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

## [v3.0.0.beta4](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta4) (2013-12-05)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta3...v3.0.0.beta4)

**Implemented enhancements:**

- Properly handle non 200 responses from Berkshelf-API [\#843](https://github.com/berkshelf/berkshelf/issues/843)
- Installer/setup script [\#743](https://github.com/berkshelf/berkshelf/issues/743)
- In memory API Server [\#730](https://github.com/berkshelf/berkshelf/issues/730)
- No proxy support for Community::REST [\#656](https://github.com/berkshelf/berkshelf/issues/656)

**Fixed bugs:**

- lockfile error [\#888](https://github.com/berkshelf/berkshelf/issues/888)
- Berks invoked from rspec/chefspec creates deeply nested vendor directory [\#828](https://github.com/berkshelf/berkshelf/issues/828)
- Installer doesn't always install all dependencies on first run [\#764](https://github.com/berkshelf/berkshelf/issues/764)
- locked\_version must be present for all items in Lockfile [\#934](https://github.com/berkshelf/berkshelf/pull/934) ([reset](https://github.com/reset))
- berks apply is an action on a lockfile, not a berksfile [\#933](https://github.com/berkshelf/berkshelf/pull/933) ([reset](https://github.com/reset))
- metadata.rb should be compiled into metadata.json before vendoring [\#923](https://github.com/berkshelf/berkshelf/pull/923) ([reset](https://github.com/reset))

**Closed issues:**

- Vendoring removes the metadata.rb breaking foodcritic [\#931](https://github.com/berkshelf/berkshelf/issues/931)
- crash on mac os x [\#929](https://github.com/berkshelf/berkshelf/issues/929)
- Install sometimes fails due to logging bug [\#928](https://github.com/berkshelf/berkshelf/issues/928)
- Lockfile conversion failing [\#924](https://github.com/berkshelf/berkshelf/issues/924)
- Clarify in docs that Berkshelf reads knife.rb [\#921](https://github.com/berkshelf/berkshelf/issues/921)
- Building universe error or Server 503 message. [\#911](https://github.com/berkshelf/berkshelf/issues/911)
- Identify speed improvements [\#899](https://github.com/berkshelf/berkshelf/issues/899)
- Flag to skip "recommends" dependencies [\#895](https://github.com/berkshelf/berkshelf/issues/895)
- Catch "invalid file" error thrown by Chef 11 when files are in the wrong directories [\#894](https://github.com/berkshelf/berkshelf/issues/894)
- How to have a local path dependency also be a metadata dependency? [\#892](https://github.com/berkshelf/berkshelf/issues/892)
- Cookbook dependency workings unclear [\#891](https://github.com/berkshelf/berkshelf/issues/891)
- `berks upload` raises several warnings before exiting [\#887](https://github.com/berkshelf/berkshelf/issues/887)
- Segmentation fault in beta3 with Maverick when running berks upload [\#884](https://github.com/berkshelf/berkshelf/issues/884)
- Make skip messages more accurate [\#882](https://github.com/berkshelf/berkshelf/issues/882)
- berks install tries to install unknown cookbook [\#878](https://github.com/berkshelf/berkshelf/issues/878)
- Can't get cookbook with tag on github working \(using nexus-cookbook\) [\#877](https://github.com/berkshelf/berkshelf/issues/877)
- Fix skip\_syntax\_check flag [\#876](https://github.com/berkshelf/berkshelf/issues/876)
- git location incorrectly displays branch as master [\#867](https://github.com/berkshelf/berkshelf/issues/867)
- Bump celluoid and use new testing mode [\#859](https://github.com/berkshelf/berkshelf/issues/859)
- Managing environment attributes along with using berks apply [\#846](https://github.com/berkshelf/berkshelf/issues/846)
- Add helpful output if github location in Berksfile ends with .git [\#845](https://github.com/berkshelf/berkshelf/issues/845)
- Berkshelf ignores metadata.rb dependency versions [\#836](https://github.com/berkshelf/berkshelf/issues/836)
- Berksfile.lock changes based on --except and --only install flags [\#796](https://github.com/berkshelf/berkshelf/issues/796)
- Doing bundle exec berks list consumes 100% CPU, over 13GB memory, takes forever. [\#793](https://github.com/berkshelf/berkshelf/issues/793)
- Add CHANGELOG entry for 2.0.8 [\#792](https://github.com/berkshelf/berkshelf/issues/792)
- Possible issue with Berksfile 'github' shortcut in 2.0.8 [\#791](https://github.com/berkshelf/berkshelf/issues/791)
- Cygwin/Windows BerksfileReadError [\#784](https://github.com/berkshelf/berkshelf/issues/784)
- Document new `berks outdated` [\#756](https://github.com/berkshelf/berkshelf/issues/756)
- Vagrant, chef-client; SSL certificate verify still failing [\#750](https://github.com/berkshelf/berkshelf/issues/750)
- Generic superclass for HTTP response/request errors [\#739](https://github.com/berkshelf/berkshelf/issues/739)

**Merged pull requests:**

- Ensure Berksfile.lock goes along with vendored cookbooks [\#935](https://github.com/berkshelf/berkshelf/pull/935) ([reset](https://github.com/reset))
- Fix for tests on Windows [\#926](https://github.com/berkshelf/berkshelf/pull/926) ([rarenerd](https://github.com/rarenerd))
- generate instructions for using edge berkshelf + vagrant-berkshelf [\#925](https://github.com/berkshelf/berkshelf/pull/925) ([reset](https://github.com/reset))
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

**Fixed bugs:**

- berks apply doesn't seem to be formatting versions properly for chef server 11 [\#760](https://github.com/berkshelf/berkshelf/issues/760)

**Closed issues:**

- simplify running a cookbook directly from Berkshelf [\#862](https://github.com/berkshelf/berkshelf/issues/862)
- Installing Berkshelf on Windows 7 w/ Cygwin [\#860](https://github.com/berkshelf/berkshelf/issues/860)
- Dependency conflicts between Berkshelf/Chef and Berkshelf/knife-ec2. [\#854](https://github.com/berkshelf/berkshelf/issues/854)
- Managing Chef Environments [\#852](https://github.com/berkshelf/berkshelf/issues/852)
- port cached cookbook loading fixes from \#829 [\#830](https://github.com/berkshelf/berkshelf/issues/830)
- Berks install indicates using the wrong branch while installing cookbooks from a git repository [\#798](https://github.com/berkshelf/berkshelf/issues/798)

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

**Implemented enhancements:**

- Accept an environment variable to debug solve [\#824](https://github.com/berkshelf/berkshelf/pull/824) ([sethvargo](https://github.com/sethvargo))

**Fixed bugs:**

- 3.0.0beta2: knife.rb sets paths relative to itself, but berks is evaluating it relative to berks run directory [\#808](https://github.com/berkshelf/berkshelf/issues/808)
- `berks init` should raise a friendly error if the current directory does not contain a cookbook [\#821](https://github.com/berkshelf/berkshelf/pull/821) ([reset](https://github.com/reset))

**Closed issues:**

- Newb question... does Berkfile go in with my application code? or would this be a separate repo? [\#826](https://github.com/berkshelf/berkshelf/issues/826)
- Dependancies of Dependancies [\#825](https://github.com/berkshelf/berkshelf/issues/825)
- `berks init` trying to overwrite files instead of append [\#823](https://github.com/berkshelf/berkshelf/issues/823)
- berks init fails with: undefined method 'name' [\#816](https://github.com/berkshelf/berkshelf/issues/816)
- `berks install` does not honor Berkshelf.lock transitive dependencies [\#815](https://github.com/berkshelf/berkshelf/issues/815)
- Ridley::Connection crashed! [\#814](https://github.com/berkshelf/berkshelf/issues/814)

**Merged pull requests:**

- Avoid reloading each cached cookbook on every resolve [\#829](https://github.com/berkshelf/berkshelf/pull/829) ([kainosnoema](https://github.com/kainosnoema))
- Allow chef client name and key to be overridden for cookbook uploads [\#818](https://github.com/berkshelf/berkshelf/pull/818) ([keiths-osc](https://github.com/keiths-osc))
- Allow chef client name and key to be overridden for cookbook uploads [\#817](https://github.com/berkshelf/berkshelf/pull/817) ([keiths-osc](https://github.com/keiths-osc))
- generate new Vagrantfile's with 1.9 style hashes [\#813](https://github.com/berkshelf/berkshelf/pull/813) ([reset](https://github.com/reset))

## [v2.0.9](https://github.com/berkshelf/berkshelf/tree/v2.0.9) (2013-08-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.8...v2.0.9)

**Implemented enhancements:**

- Refactor ChefIgnore [\#748](https://github.com/berkshelf/berkshelf/pull/748) ([sethvargo](https://github.com/sethvargo))

**Fixed bugs:**

- berks update/install fails with \[No Berksfile or Berksfile.lock found at: ...\] [\#787](https://github.com/berkshelf/berkshelf/issues/787)
- Installing under ruby 2.0 on x64 Windows w/ devkit fails to compile dependency [\#774](https://github.com/berkshelf/berkshelf/issues/774)
- When uploading a cookbook, Berkshelf fails to locate a cookbook's dependencies despite those dependencies being explicitly defined in the Berksfile [\#369](https://github.com/berkshelf/berkshelf/issues/369)

**Closed issues:**

- 3.0.0beta2: chef\_config processing fails if there are knife option assignments in knife.rb [\#807](https://github.com/berkshelf/berkshelf/issues/807)
- Dependencies' Berksfiles should not be ignored [\#804](https://github.com/berkshelf/berkshelf/issues/804)
- Berkshelf will delete berksfile , gemfile ? [\#803](https://github.com/berkshelf/berkshelf/issues/803)
- Unable to upload cookbooks through an open SSH tunnel [\#802](https://github.com/berkshelf/berkshelf/issues/802)
- berks install --path deletes everything in the target directory [\#801](https://github.com/berkshelf/berkshelf/issues/801)
- Bad Berkshelf store path with multiple box on VirtualBox with Vagrant [\#795](https://github.com/berkshelf/berkshelf/issues/795)
- bundle exec contingent mysql fails with ENOENT [\#794](https://github.com/berkshelf/berkshelf/issues/794)
- Berkshelf init must be atomic [\#789](https://github.com/berkshelf/berkshelf/issues/789)

**Merged pull requests:**

- Bump ridley [\#812](https://github.com/berkshelf/berkshelf/pull/812) ([reset](https://github.com/reset))
- Dependencies with a path location take precedence over locked ones [\#809](https://github.com/berkshelf/berkshelf/pull/809) ([reset](https://github.com/reset))
- Support -h and --help flags on subcommands [\#806](https://github.com/berkshelf/berkshelf/pull/806) ([sethvargo](https://github.com/sethvargo))
- Enable use of vagrant-omnibus plugin in generated vagrant files [\#799](https://github.com/berkshelf/berkshelf/pull/799) ([pghalliday](https://github.com/pghalliday))
- Fixed bash-completion directory path [\#797](https://github.com/berkshelf/berkshelf/pull/797) ([chrisyunker](https://github.com/chrisyunker))
- Missing backtick on incompatible version error [\#782](https://github.com/berkshelf/berkshelf/pull/782) ([fromonesrc](https://github.com/fromonesrc))
- Use HTTPS by default for community API [\#775](https://github.com/berkshelf/berkshelf/pull/775) ([coderanger](https://github.com/coderanger))
- Fix issue where location is nil for cookbook that is in the cache [\#772](https://github.com/berkshelf/berkshelf/pull/772) ([b-dean](https://github.com/b-dean))

## [v2.0.8](https://github.com/berkshelf/berkshelf/tree/v2.0.8) (2013-08-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta2...v2.0.8)

**Fixed bugs:**

- berks upload --ssl-verify=false does not work [\#758](https://github.com/berkshelf/berkshelf/issues/758)

**Closed issues:**

- Berkshelf init must create files with OS line endings [\#790](https://github.com/berkshelf/berkshelf/issues/790)
- Inconsistent ridley dependency between berkshelf and berkshelf-api [\#788](https://github.com/berkshelf/berkshelf/issues/788)
- berks install removes custom cookbooks [\#785](https://github.com/berkshelf/berkshelf/issues/785)
- Berkshelf uses old versions of cookbooks even when new ones are available [\#781](https://github.com/berkshelf/berkshelf/issues/781)

**Merged pull requests:**

- relax constraint on ridley to ~\> 1.5 [\#786](https://github.com/berkshelf/berkshelf/pull/786) ([reset](https://github.com/reset))
- bump required solve version \>= 0.8.0 [\#783](https://github.com/berkshelf/berkshelf/pull/783) ([reset](https://github.com/reset))
- From bug https://github.com/RiotGames/berkshelf/issues/758 [\#778](https://github.com/berkshelf/berkshelf/pull/778) ([riotcku](https://github.com/riotcku))
- clean hard tabs [\#771](https://github.com/berkshelf/berkshelf/pull/771) ([j4y](https://github.com/j4y))
- When Cucumber can’t find a matching Step Definition [\#768](https://github.com/berkshelf/berkshelf/pull/768) ([sethvargo](https://github.com/sethvargo))
- @tknerr metadata deps not honored [\#717](https://github.com/berkshelf/berkshelf/pull/717) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta2](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta2) (2013-07-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v3.0.0.beta1...v3.0.0.beta2)

**Implemented enhancements:**

- Improve message when skipping uploading a cookbook because it's frozen [\#689](https://github.com/berkshelf/berkshelf/issues/689)
- proposal on installing cookbooks from subversion [\#672](https://github.com/berkshelf/berkshelf/issues/672)
- proposal on installing cookbooks from subversion [\#672](https://github.com/berkshelf/berkshelf/issues/672)
- Default git source [\#615](https://github.com/berkshelf/berkshelf/issues/615)
- Hosted Berkshelf DependencyAPI [\#397](https://github.com/berkshelf/berkshelf/issues/397)
- add 'search' command [\#384](https://github.com/berkshelf/berkshelf/issues/384)
- Berkshelf support for Mercurial [\#354](https://github.com/berkshelf/berkshelf/issues/354)
- Use Ridley::Chef::Config [\#741](https://github.com/berkshelf/berkshelf/pull/741) ([sethvargo](https://github.com/sethvargo))
- `berks show` should not install cookbooks for the end user [\#740](https://github.com/berkshelf/berkshelf/pull/740) ([reset](https://github.com/reset))
- Properly implement `berks outdated` [\#731](https://github.com/berkshelf/berkshelf/pull/731) ([reset](https://github.com/reset))
- `berks vendor` command to replace `berks install --path` [\#729](https://github.com/berkshelf/berkshelf/pull/729) ([reset](https://github.com/reset))

**Fixed bugs:**

- Undefined method "validate\_cached", resolver.rb \(line 166, in use\_source\) when using Berkshelf in conjunction with Vagrant \(+plugin\) [\#718](https://github.com/berkshelf/berkshelf/issues/718)
- berks update doesn't correctly handle multiple nested dependencies [\#250](https://github.com/berkshelf/berkshelf/issues/250)
- `Berks package` should packaging properly for chef-solo  [\#749](https://github.com/berkshelf/berkshelf/pull/749) ([johntdyer](https://github.com/johntdyer))

**Closed issues:**

- the `--path` flag not working on latest beta [\#759](https://github.com/berkshelf/berkshelf/issues/759)
- Locked version constraints ignored [\#751](https://github.com/berkshelf/berkshelf/issues/751)
- berks install -p=cookbooks copies cookbooks dir into itself [\#747](https://github.com/berkshelf/berkshelf/issues/747)
- Lockfile site format handled incorrectly [\#745](https://github.com/berkshelf/berkshelf/issues/745)
- ctags generated by git hooks cause berks install to fail [\#738](https://github.com/berkshelf/berkshelf/issues/738)
- 'berks install' deletes all things when used incorrectly [\#726](https://github.com/berkshelf/berkshelf/issues/726)
- Add `berks apply\_metadata` command [\#724](https://github.com/berkshelf/berkshelf/issues/724)
- Guard is broken :\( [\#702](https://github.com/berkshelf/berkshelf/issues/702)
- berks upload \<single\_cookbook\> doesn't seem to work [\#701](https://github.com/berkshelf/berkshelf/issues/701)
- Berkshelf 2.0.5 does not honor --skip-dependencies [\#699](https://github.com/berkshelf/berkshelf/issues/699)
- Does not fail on conflicting dependency in git and metadata [\#691](https://github.com/berkshelf/berkshelf/issues/691)
- Unable to locate cookbooks using path: in transitive dependencies [\#690](https://github.com/berkshelf/berkshelf/issues/690)
- Uploading frozen cookbooks are silently ignored [\#688](https://github.com/berkshelf/berkshelf/issues/688)
- Don't rely on \#to\_s for a dependency's name [\#649](https://github.com/berkshelf/berkshelf/issues/649)
- Upload command does not respect chefignore [\#587](https://github.com/berkshelf/berkshelf/issues/587)
- berks outdated not doing The Thing [\#467](https://github.com/berkshelf/berkshelf/issues/467)
- Failures creating cookbooks directory properly [\#421](https://github.com/berkshelf/berkshelf/issues/421)
- add outdated to documentation [\#361](https://github.com/berkshelf/berkshelf/issues/361)

**Merged pull requests:**

- skip uploading an already uploaded metadata dependency [\#769](https://github.com/berkshelf/berkshelf/pull/769) ([reset](https://github.com/reset))
- Fix skipped outdated formatter [\#767](https://github.com/berkshelf/berkshelf/pull/767) ([sethvargo](https://github.com/sethvargo))
- Berksfile.lock overwritten? [\#765](https://github.com/berkshelf/berkshelf/pull/765) ([sfiggins](https://github.com/sfiggins))
- Fix a lost commit [\#763](https://github.com/berkshelf/berkshelf/pull/763) ([sethvargo](https://github.com/sethvargo))
- change default vendor location to 'berks-cookbooks' [\#757](https://github.com/berkshelf/berkshelf/pull/757) ([reset](https://github.com/reset))
- Don't install cookbooks when looking for outdated ones [\#755](https://github.com/berkshelf/berkshelf/pull/755) ([sethvargo](https://github.com/sethvargo))
- Only show failing specs and cukes on Travis [\#753](https://github.com/berkshelf/berkshelf/pull/753) ([sethvargo](https://github.com/sethvargo))
- Listen to the lockfile [\#752](https://github.com/berkshelf/berkshelf/pull/752) ([sethvargo](https://github.com/sethvargo))
- Mercurial Support \(rebased\) [\#746](https://github.com/berkshelf/berkshelf/pull/746) ([mryan43](https://github.com/mryan43))
- Remove unused fixtures [\#744](https://github.com/berkshelf/berkshelf/pull/744) ([sethvargo](https://github.com/sethvargo))
- Fix RSpec deprecation error [\#742](https://github.com/berkshelf/berkshelf/pull/742) ([sethvargo](https://github.com/sethvargo))
- Rescue all errors, include Errno::EDENT [\#736](https://github.com/berkshelf/berkshelf/pull/736) ([sethvargo](https://github.com/sethvargo))
- Rescue all errors when evaluating the Berksfile [\#735](https://github.com/berkshelf/berkshelf/pull/735) ([sethvargo](https://github.com/sethvargo))
- Just output the version string instead of License and Authors as well [\#733](https://github.com/berkshelf/berkshelf/pull/733) ([sethvargo](https://github.com/sethvargo))
- Always raise exception when uploading a metadata frozen cookbook [\#692](https://github.com/berkshelf/berkshelf/pull/692) ([sethvargo](https://github.com/sethvargo))
- Fix lockfile speed issues \(master\) [\#684](https://github.com/berkshelf/berkshelf/pull/684) ([sethvargo](https://github.com/sethvargo))

## [v3.0.0.beta1](https://github.com/berkshelf/berkshelf/tree/v3.0.0.beta1) (2013-07-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.7...v3.0.0.beta1)

**Merged pull requests:**

- Use the Berkshelf API Server in the resolver [\#693](https://github.com/berkshelf/berkshelf/pull/693) ([reset](https://github.com/reset))

## [v2.0.7](https://github.com/berkshelf/berkshelf/tree/v2.0.7) (2013-07-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.6...v2.0.7)

**Closed issues:**

- Unhandled exception when using berkshelf, hosted chef and vagrant [\#737](https://github.com/berkshelf/berkshelf/issues/737)
- berks install produces an error with the -b option under certain conditions [\#721](https://github.com/berkshelf/berkshelf/issues/721)

**Merged pull requests:**

- Fix generator files to allow multiple hyphens in cookbook\_name [\#732](https://github.com/berkshelf/berkshelf/pull/732) ([maoe](https://github.com/maoe))
- Lockfile load 2 0 stable [\#728](https://github.com/berkshelf/berkshelf/pull/728) ([sethvargo](https://github.com/sethvargo))
- Rescue CookbookNotFound in lockfile\#load! [\#727](https://github.com/berkshelf/berkshelf/pull/727) ([sethvargo](https://github.com/sethvargo))
- Fixing issue with relative cookbook paths while processing a Berksfile \(Issue 721\) [\#723](https://github.com/berkshelf/berkshelf/pull/723) ([krmichelos](https://github.com/krmichelos))
- Fixing issue with relative cookbook paths while processing a Berksfile \(Issue 721\) [\#722](https://github.com/berkshelf/berkshelf/pull/722) ([krmichelos](https://github.com/krmichelos))
- Fixed 'greater than equal to' symbol in index.md [\#720](https://github.com/berkshelf/berkshelf/pull/720) ([kppullin](https://github.com/kppullin))

## [v2.0.6](https://github.com/berkshelf/berkshelf/tree/v2.0.6) (2013-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.5...v2.0.6)

**Fixed bugs:**

- dropping git, ref attributes from a source in a berks install [\#674](https://github.com/berkshelf/berkshelf/issues/674)

**Closed issues:**

- ref no longer a functional alias for branch [\#713](https://github.com/berkshelf/berkshelf/issues/713)
- Version Constraint in metadata.rb not honored [\#709](https://github.com/berkshelf/berkshelf/issues/709)
- Uploading cookbook with Unicode characters [\#708](https://github.com/berkshelf/berkshelf/issues/708)
- Cookbooks with git sources are not updated when calling berks update [\#707](https://github.com/berkshelf/berkshelf/issues/707)
- Berkshelf cannot find the Berksfile [\#705](https://github.com/berkshelf/berkshelf/issues/705)
- Get a 'Ridley::SandboxResource crashed! Celluloid::FiberStackError: stack level too deep' error when uploading cookbooks  [\#703](https://github.com/berkshelf/berkshelf/issues/703)
- Investigate autostart [\#685](https://github.com/berkshelf/berkshelf/issues/685)

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

**Fixed bugs:**

- Berkshelf config is not reloaded  [\#664](https://github.com/berkshelf/berkshelf/issues/664)
- Berksfile.lock's `locked\_version` not honored when cookbook store is empty [\#637](https://github.com/berkshelf/berkshelf/issues/637)
- wrong version chosen during vagrant run [\#226](https://github.com/berkshelf/berkshelf/issues/226)
- If a Berksfile.lock is empty, berks stacktraces trying to read it [\#686](https://github.com/berkshelf/berkshelf/pull/686) ([capoferro](https://github.com/capoferro))

**Closed issues:**

- Berkshelf ignores metadata.rb dependency versions [\#680](https://github.com/berkshelf/berkshelf/issues/680)
- berks download with git path fails with "failed to download" [\#679](https://github.com/berkshelf/berkshelf/issues/679)
- Berkshelf 2.0.4 and Chef 11 Dependency conflict [\#676](https://github.com/berkshelf/berkshelf/issues/676)
- `berks upload` failing to pass args \(like --skip-dependencies\) on Windows [\#667](https://github.com/berkshelf/berkshelf/issues/667)
- Bundler dependency error in generated cookbook [\#657](https://github.com/berkshelf/berkshelf/issues/657)
- berks upload fails with undefined method `success?' [\#627](https://github.com/berkshelf/berkshelf/issues/627)

**Merged pull requests:**

- Gracefully fail LockfileParserError and handle empty lockfiles [\#687](https://github.com/berkshelf/berkshelf/pull/687) ([sethvargo](https://github.com/sethvargo))
- Fix lockfile speed issues \(2-0-stable\) [\#683](https://github.com/berkshelf/berkshelf/pull/683) ([sethvargo](https://github.com/sethvargo))
- Forwardport lockfile fixes [\#681](https://github.com/berkshelf/berkshelf/pull/681) ([sethvargo](https://github.com/sethvargo))
- remove dependency on active support [\#678](https://github.com/berkshelf/berkshelf/pull/678) ([reset](https://github.com/reset))
- run unit and acceptance tests at the same time [\#677](https://github.com/berkshelf/berkshelf/pull/677) ([reset](https://github.com/reset))
- handle gzipped responses from the community site [\#675](https://github.com/berkshelf/berkshelf/pull/675) ([reset](https://github.com/reset))
- replace Chozo::Config with Buff::Config [\#673](https://github.com/berkshelf/berkshelf/pull/673) ([reset](https://github.com/reset))

## [v2.0.4](https://github.com/berkshelf/berkshelf/tree/v2.0.4) (2013-06-17)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.6...v2.0.4)

**Fixed bugs:**

- Regression in speed improvements when installing with a Berksfile.lock [\#646](https://github.com/berkshelf/berkshelf/pull/646) ([reset](https://github.com/reset))
- `berks install` should not write a locked version for a cookbook installed by `metadata` [\#623](https://github.com/berkshelf/berkshelf/pull/623) ([reset](https://github.com/reset))

**Closed issues:**

- berks upload fails consistently during the upload of cookbook 'ohai' [\#661](https://github.com/berkshelf/berkshelf/issues/661)
- Duplicate code? [\#660](https://github.com/berkshelf/berkshelf/issues/660)
- custom path in 'berks install' fails when having rel and trying to install with --path [\#654](https://github.com/berkshelf/berkshelf/issues/654)

**Merged pull requests:**

- Rename lockfile sources to dependencies [\#665](https://github.com/berkshelf/berkshelf/pull/665) ([sethvargo](https://github.com/sethvargo))
- Read error message master \(3.0\) [\#663](https://github.com/berkshelf/berkshelf/pull/663) ([sethvargo](https://github.com/sethvargo))
- Read error message in BerksfileReadError \(2.0\) [\#662](https://github.com/berkshelf/berkshelf/pull/662) ([sethvargo](https://github.com/sethvargo))
- Remove explicit TK Dependency [\#659](https://github.com/berkshelf/berkshelf/pull/659) ([reset](https://github.com/reset))
- Use .values instead of mapping the hash \(3.0\) [\#653](https://github.com/berkshelf/berkshelf/pull/653) ([sethvargo](https://github.com/sethvargo))
- Use .values instead of mapping the hash \(2.0\) [\#652](https://github.com/berkshelf/berkshelf/pull/652) ([sethvargo](https://github.com/sethvargo))
- Remove a test that creeped in from master [\#651](https://github.com/berkshelf/berkshelf/pull/651) ([sethvargo](https://github.com/sethvargo))
- Fix broken metadata constraints [\#648](https://github.com/berkshelf/berkshelf/pull/648) ([sethvargo](https://github.com/sethvargo))
- rename cookbook source/sources to dependency/dependencies [\#640](https://github.com/berkshelf/berkshelf/pull/640) ([reset](https://github.com/reset))
- File syntax check [\#632](https://github.com/berkshelf/berkshelf/pull/632) ([sethvargo](https://github.com/sethvargo))

## [v1.4.6](https://github.com/berkshelf/berkshelf/tree/v1.4.6) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.3...v1.4.6)

**Fixed bugs:**

- metadata.rb constraints are not respected [\#494](https://github.com/berkshelf/berkshelf/issues/494)
- cached relative path of git repo broken in 2.0.1 [\#629](https://github.com/berkshelf/berkshelf/pull/629) ([bhouse](https://github.com/bhouse))

**Closed issues:**

- :git locations broken / shellout problem [\#633](https://github.com/berkshelf/berkshelf/issues/633)
- Berkshelf ignores version constraints in metadata when there is already a version of the cookbook installed. [\#103](https://github.com/berkshelf/berkshelf/issues/103)

**Merged pull requests:**

- Merge pull request \#629 from RiotGames/rel\_lockfile [\#644](https://github.com/berkshelf/berkshelf/pull/644) ([reset](https://github.com/reset))
- Merge pull request \#642 from RiotGames/use-mixin-shellout [\#643](https://github.com/berkshelf/berkshelf/pull/643) ([reset](https://github.com/reset))
- use Mixin::ShellOut instead of Ridley::Mixin::ShellOut [\#642](https://github.com/berkshelf/berkshelf/pull/642) ([reset](https://github.com/reset))
- Add bzip2 tarball support [\#641](https://github.com/berkshelf/berkshelf/pull/641) ([pdf](https://github.com/pdf))
- Fix metadata nested constraints [\#626](https://github.com/berkshelf/berkshelf/pull/626) ([sethvargo](https://github.com/sethvargo))
- Full backport default locations [\#598](https://github.com/berkshelf/berkshelf/pull/598) ([sethvargo](https://github.com/sethvargo))

## [v2.0.3](https://github.com/berkshelf/berkshelf/tree/v2.0.3) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.2...v2.0.3)

**Merged pull requests:**

- pass blocks to methods exposed by Mixin::DSLEval [\#638](https://github.com/berkshelf/berkshelf/pull/638) ([reset](https://github.com/reset))

## [v2.0.2](https://github.com/berkshelf/berkshelf/tree/v2.0.2) (2013-06-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.1...v2.0.2)

**Implemented enhancements:**

- Vagrant chef\_client provisioner not reflecting on Berks configuration for it's values [\#225](https://github.com/berkshelf/berkshelf/issues/225)

**Fixed bugs:**

- Unknown license error when running `berks cookbook` [\#624](https://github.com/berkshelf/berkshelf/pull/624) ([dougireton](https://github.com/dougireton))

**Closed issues:**

- Berkshelf 2.0.1 does not honor --skip-dependencies [\#628](https://github.com/berkshelf/berkshelf/issues/628)
- Changelog for 1.4.5 [\#616](https://github.com/berkshelf/berkshelf/issues/616)
- Backport default location fixes to 1.4-stable [\#577](https://github.com/berkshelf/berkshelf/issues/577)

**Merged pull requests:**

- use Ridley's ShellOut to fix issues with thread saftey and windows [\#636](https://github.com/berkshelf/berkshelf/pull/636) ([reset](https://github.com/reset))
- move thor/monkies to thor\_ext [\#635](https://github.com/berkshelf/berkshelf/pull/635) ([reset](https://github.com/reset))
- only expose methods we want to the Berksfile DSL [\#634](https://github.com/berkshelf/berkshelf/pull/634) ([reset](https://github.com/reset))
- berks upload --skip-dependencies goes down in flames [\#631](https://github.com/berkshelf/berkshelf/pull/631) ([thommay](https://github.com/thommay))

## [v2.0.1](https://github.com/berkshelf/berkshelf/tree/v2.0.1) (2013-06-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.0...v2.0.1)

**Fixed bugs:**

- CLI does not actually respect the `-c` flag [\#622](https://github.com/berkshelf/berkshelf/pull/622) ([reset](https://github.com/reset))
- Debug/Verbose logging is broken [\#621](https://github.com/berkshelf/berkshelf/pull/621) ([reset](https://github.com/reset))

**Merged pull requests:**

- Berksfile will now be installed instead of resolved before upload [\#620](https://github.com/berkshelf/berkshelf/pull/620) ([reset](https://github.com/reset))
- Bump .ruby-version to 1.9.3-p429 \[ci skip\] [\#619](https://github.com/berkshelf/berkshelf/pull/619) ([sethvargo](https://github.com/sethvargo))
- Fixing the version location in outdated source error message [\#618](https://github.com/berkshelf/berkshelf/pull/618) ([jeremyolliver](https://github.com/jeremyolliver))

## [v2.0.0](https://github.com/berkshelf/berkshelf/tree/v2.0.0) (2013-06-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.5...v2.0.0)

**Implemented enhancements:**

- Add Proxy Support [\#243](https://github.com/berkshelf/berkshelf/issues/243)
- `berks shelf show` should take an optional VERSION argument [\#586](https://github.com/berkshelf/berkshelf/pull/586) ([reset](https://github.com/reset))
- Allow user to specify licenses [\#543](https://github.com/berkshelf/berkshelf/pull/543) ([sethvargo](https://github.com/sethvargo))
- Cookbook validation should be performed on `package` command [\#536](https://github.com/berkshelf/berkshelf/pull/536) ([reset](https://github.com/reset))

**Fixed bugs:**

- Identify Ruby 1.9.2 "Random" Failures? [\#595](https://github.com/berkshelf/berkshelf/issues/595)
- knife.rb resolution logic doesn't seem to work [\#537](https://github.com/berkshelf/berkshelf/issues/537)
- Berks cookbook misplaces files [\#603](https://github.com/berkshelf/berkshelf/pull/603) ([sethvargo](https://github.com/sethvargo))

**Closed issues:**

- Cookbook generation of Vagrantfile has double quoted string for box name and box\_url [\#612](https://github.com/berkshelf/berkshelf/issues/612)
- Berkshelf documentation is offline [\#605](https://github.com/berkshelf/berkshelf/issues/605)
- Vendor related feature request - downloading cookbook files [\#604](https://github.com/berkshelf/berkshelf/issues/604)
- :git locations broken? [\#601](https://github.com/berkshelf/berkshelf/issues/601)
- Support for Vendoring Cookbooks [\#597](https://github.com/berkshelf/berkshelf/issues/597)
- berks install with --berksfile option does not work [\#594](https://github.com/berkshelf/berkshelf/issues/594)
- When using multiple default locations, only the first location is used [\#588](https://github.com/berkshelf/berkshelf/issues/588)
- Vagrant run list  [\#584](https://github.com/berkshelf/berkshelf/issues/584)
- Anyone feeling berks install/upload commands too slow? [\#549](https://github.com/berkshelf/berkshelf/issues/549)
- Hide TK related things for 2.0 [\#547](https://github.com/berkshelf/berkshelf/issues/547)
- Berks Install Not Parsing Cookbook API properly [\#542](https://github.com/berkshelf/berkshelf/issues/542)
- chef\_handler run very slow [\#540](https://github.com/berkshelf/berkshelf/issues/540)
- Berks init/cookbook generate a Vagrantfile that throws an undefined method error if berkshelf-vagrant is installed. [\#539](https://github.com/berkshelf/berkshelf/issues/539)
- berks install fails on windows/cygwin when you specify a coobkook in Berksfile [\#522](https://github.com/berkshelf/berkshelf/issues/522)
- Berkshelf cannot upload to multiple locations without re-resolving dependencies [\#462](https://github.com/berkshelf/berkshelf/issues/462)
- When the requested version is not available on the chef server, the latest version is accepted [\#294](https://github.com/berkshelf/berkshelf/issues/294)
- Using metadata should not resolve "self" [\#263](https://github.com/berkshelf/berkshelf/issues/263)
- Berkshelf should ascend directories looking for Berksfile [\#166](https://github.com/berkshelf/berkshelf/issues/166)

**Merged pull requests:**

- test command registered to the CLI properly [\#610](https://github.com/berkshelf/berkshelf/pull/610) ([reset](https://github.com/reset))
- remove all @author tags from source - rely on gemspec/readme/license [\#609](https://github.com/berkshelf/berkshelf/pull/609) ([reset](https://github.com/reset))
- add Seth Vargo to authors list [\#608](https://github.com/berkshelf/berkshelf/pull/608) ([reset](https://github.com/reset))
- remove quotes around `ref` as they will break `:git` locations \(at least... [\#602](https://github.com/berkshelf/berkshelf/pull/602) ([tknerr](https://github.com/tknerr))
- Turns out the default sites were actually broken... [\#599](https://github.com/berkshelf/berkshelf/pull/599) ([sethvargo](https://github.com/sethvargo))
- Don't generate real keys [\#596](https://github.com/berkshelf/berkshelf/pull/596) ([sethvargo](https://github.com/sethvargo))
- Take \#2 at replacing MixLib::Shellout [\#593](https://github.com/berkshelf/berkshelf/pull/593) ([sethvargo](https://github.com/sethvargo))
- Chef Zero still broken [\#592](https://github.com/berkshelf/berkshelf/pull/592) ([sethvargo](https://github.com/sethvargo))
- Bring berkshelf specs up to the latest chef-zero [\#589](https://github.com/berkshelf/berkshelf/pull/589) ([jkeiser](https://github.com/jkeiser))
- :json is not registered on Faraday::Response \(RuntimeError\) [\#581](https://github.com/berkshelf/berkshelf/pull/581) ([mconigliaro](https://github.com/mconigliaro))
- Create `berks shelf` [\#579](https://github.com/berkshelf/berkshelf/pull/579) ([sethvargo](https://github.com/sethvargo))
- Convert many things to single quotes [\#575](https://github.com/berkshelf/berkshelf/pull/575) ([sethvargo](https://github.com/sethvargo))
- Remove mixlib-config as a dependency [\#571](https://github.com/berkshelf/berkshelf/pull/571) ([sethvargo](https://github.com/sethvargo))
- Speed up \#show command and operate off a Berksfile [\#564](https://github.com/berkshelf/berkshelf/pull/564) ([sethvargo](https://github.com/sethvargo))
- Require a Berksfile for the \#info command [\#563](https://github.com/berkshelf/berkshelf/pull/563) ([sethvargo](https://github.com/sethvargo))
- Speed up Lockfile feature [\#559](https://github.com/berkshelf/berkshelf/pull/559) ([sethvargo](https://github.com/sethvargo))

## [v1.4.5](https://github.com/berkshelf/berkshelf/tree/v1.4.5) (2013-05-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v2.0.0.beta...v1.4.5)

**Fixed bugs:**

- Recipes with spaces in the filename cause `berks upload` to fail [\#530](https://github.com/berkshelf/berkshelf/issues/530)
- Lockfile 2.0 should use a relative path for a metadata cookbook [\#529](https://github.com/berkshelf/berkshelf/issues/529)
- Default locations are broken [\#516](https://github.com/berkshelf/berkshelf/pull/516) ([sethvargo](https://github.com/sethvargo))

**Closed issues:**

- Why uploads all the cookbooks when issuing cmd to upload one cookbook only? [\#574](https://github.com/berkshelf/berkshelf/issues/574)
- How to use Berkshelf to manage Organization repo like the Librarian-chef does? [\#535](https://github.com/berkshelf/berkshelf/issues/535)
- Lockfile 2 breaks cookbooks located on a relative path [\#532](https://github.com/berkshelf/berkshelf/issues/532)
- Tests on master are terribly slow due to test-kitchen integration [\#531](https://github.com/berkshelf/berkshelf/issues/531)
- cookbook repo pointing to github in Berksfile is not finding it on berks upload [\#528](https://github.com/berkshelf/berkshelf/issues/528)
- Berks Upload fails behind a proxy [\#524](https://github.com/berkshelf/berkshelf/issues/524)
- berks apply errors out during environment.save [\#520](https://github.com/berkshelf/berkshelf/issues/520)
- berks apply errors out during environment.save [\#519](https://github.com/berkshelf/berkshelf/issues/519)
- berks apply errors out during environment.save [\#518](https://github.com/berkshelf/berkshelf/issues/518)
- Deprecate Berksfile in favor of .berkshelf [\#517](https://github.com/berkshelf/berkshelf/issues/517)
- vendor\_path option in config for default --path for install  [\#512](https://github.com/berkshelf/berkshelf/issues/512)

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

## [v2.0.0.beta](https://github.com/berkshelf/berkshelf/tree/v2.0.0.beta) (2013-05-15)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.4...v2.0.0.beta)

**Closed issues:**

- berks package [\#509](https://github.com/berkshelf/berkshelf/issues/509)
- No option to disable default behavior of stripping .git/ directories on `berks install` git cookbooks [\#496](https://github.com/berkshelf/berkshelf/issues/496)
- Do not fetch git repo if I have it in my Berksfile.lock [\#404](https://github.com/berkshelf/berkshelf/issues/404)
- Pull `berks cookbook` templating command into new project? [\#386](https://github.com/berkshelf/berkshelf/issues/386)
- Logs misrepresent the source of a cookbook [\#295](https://github.com/berkshelf/berkshelf/issues/295)

**Merged pull requests:**

- Fix tests [\#515](https://github.com/berkshelf/berkshelf/pull/515) ([sethvargo](https://github.com/sethvargo))
- Implement `berks package` [\#510](https://github.com/berkshelf/berkshelf/pull/510) ([sethvargo](https://github.com/sethvargo))
- Test-Kitchen integration [\#435](https://github.com/berkshelf/berkshelf/pull/435) ([reset](https://github.com/reset))

## [v1.4.4](https://github.com/berkshelf/berkshelf/tree/v1.4.4) (2013-05-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.3...v1.4.4)

**Implemented enhancements:**

- upgrade to Ridley 0.11.x [\#487](https://github.com/berkshelf/berkshelf/issues/487)

**Fixed bugs:**

- `berks list -F json` should not produce both human and json output [\#488](https://github.com/berkshelf/berkshelf/issues/488)
- Issues with Vagrant plugin when "cookbooks" folder exists [\#267](https://github.com/berkshelf/berkshelf/issues/267)
- Upload breaks with space in path name [\#258](https://github.com/berkshelf/berkshelf/issues/258)

**Closed issues:**

- upload does not upload files from files/default [\#511](https://github.com/berkshelf/berkshelf/issues/511)
- Vagrant not using the lastest cookbooks [\#500](https://github.com/berkshelf/berkshelf/issues/500)
- Change specs to depend on a fixture cookbook repo [\#498](https://github.com/berkshelf/berkshelf/issues/498)
- Warn if cookbook name in Berksfile and name in metadata don't match [\#497](https://github.com/berkshelf/berkshelf/issues/497)
- berks update not updating cookbook stored in github after updating cookbook version [\#493](https://github.com/berkshelf/berkshelf/issues/493)
- Berkshelf displays color codes as garbage characters in Windows [\#482](https://github.com/berkshelf/berkshelf/issues/482)
- Allow CWD configuration file [\#476](https://github.com/berkshelf/berkshelf/issues/476)
- berks upload fails dude to fiber stack size limit [\#474](https://github.com/berkshelf/berkshelf/issues/474)
- no way to use berkshelf with environments and git changesets that should not yet be release [\#469](https://github.com/berkshelf/berkshelf/issues/469)
- vagrant plugin failed to load in windows [\#449](https://github.com/berkshelf/berkshelf/issues/449)
- Vagrant + berksfile\_path + cookbook with path option = Berkshelf::CookbookNotFound [\#436](https://github.com/berkshelf/berkshelf/issues/436)
- Error when uploading a large sandbox [\#376](https://github.com/berkshelf/berkshelf/issues/376)
- Loading the CookbookStore is slow with a lot of Cookbooks present [\#285](https://github.com/berkshelf/berkshelf/issues/285)
- validate the name of the retrieved cached\_cookbook is not different than the source [\#123](https://github.com/berkshelf/berkshelf/issues/123)

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

**Implemented enhancements:**

- apply Berksfile.lock to environment [\#440](https://github.com/berkshelf/berkshelf/issues/440)
- git SHA should be resolved in lockfile [\#486](https://github.com/berkshelf/berkshelf/pull/486) ([sethvargo](https://github.com/sethvargo))

**Fixed bugs:**

- Berks upload + open source Chef server + missing name in metadata = Ridley::Errors::HTTPBadRequest [\#442](https://github.com/berkshelf/berkshelf/issues/442)

**Closed issues:**

- Unable to install updated cookbook from github [\#495](https://github.com/berkshelf/berkshelf/issues/495)
- berkshelf dot fetch transitive dependencies with git \(include\_attribute\) [\#492](https://github.com/berkshelf/berkshelf/issues/492)
- Berksfile.lock should not entry for current cookbook [\#485](https://github.com/berkshelf/berkshelf/issues/485)
- When getting "Connection Refused" errors, Berkshelf should return a friendly error message [\#439](https://github.com/berkshelf/berkshelf/issues/439)
- Is there a way to override the generator templates? [\#437](https://github.com/berkshelf/berkshelf/issues/437)

**Merged pull requests:**

- Just use JSON [\#491](https://github.com/berkshelf/berkshelf/pull/491) ([sethvargo](https://github.com/sethvargo))
- berks apply command [\#473](https://github.com/berkshelf/berkshelf/pull/473) ([capoferro](https://github.com/capoferro))
- Is there any config file for author name/email to populate while creating cookbook? [\#391](https://github.com/berkshelf/berkshelf/pull/391) ([millisami](https://github.com/millisami))

## [v1.4.2](https://github.com/berkshelf/berkshelf/tree/v1.4.2) (2013-05-02)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.1...v1.4.2)

**Implemented enhancements:**

- Lockfile Re-write [\#274](https://github.com/berkshelf/berkshelf/issues/274)
- Clean up Chef Server on destruction if Chef Client provisioner [\#264](https://github.com/berkshelf/berkshelf/issues/264)

**Fixed bugs:**

- berks upload drops the port number in the URL [\#453](https://github.com/berkshelf/berkshelf/issues/453)

**Closed issues:**

- Orphan lockfile generated in CWD on berks cookbook [\#478](https://github.com/berkshelf/berkshelf/issues/478)
- Install command does not respect chefignore [\#432](https://github.com/berkshelf/berkshelf/issues/432)
- Remve unnecessary dependencies from lockfile [\#400](https://github.com/berkshelf/berkshelf/issues/400)
- Berkshelf middleware appears to break cookbooks mounted over NFS [\#207](https://github.com/berkshelf/berkshelf/issues/207)

**Merged pull requests:**

- Fix Git caching [\#484](https://github.com/berkshelf/berkshelf/pull/484) ([ivey](https://github.com/ivey))
- Fix `berks open` features when $VISUAL is set [\#483](https://github.com/berkshelf/berkshelf/pull/483) ([ivey](https://github.com/ivey))
- Lockfile 2.0 - cleaned branch [\#481](https://github.com/berkshelf/berkshelf/pull/481) ([reset](https://github.com/reset))

## [v1.4.1](https://github.com/berkshelf/berkshelf/tree/v1.4.1) (2013-04-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.0...v1.4.1)

**Implemented enhancements:**

- improve cookbook upload speeds [\#275](https://github.com/berkshelf/berkshelf/issues/275)
- Don't copy cookbooks for every vagrant run [\#165](https://github.com/berkshelf/berkshelf/issues/165)

**Fixed bugs:**

- Symbol arg to `site` needs better error [\#458](https://github.com/berkshelf/berkshelf/issues/458)
- chef\_server\_url not configurable for upload command [\#480](https://github.com/berkshelf/berkshelf/pull/480) ([KAllan357](https://github.com/KAllan357))

**Closed issues:**

- Dependency on cookbook README file [\#479](https://github.com/berkshelf/berkshelf/issues/479)
- Cannot upload local path cookbook when it relies on another local path cookbook [\#475](https://github.com/berkshelf/berkshelf/issues/475)
- Vagrant halt failing [\#464](https://github.com/berkshelf/berkshelf/issues/464)
- timeout when upload especific newrelic cookbook [\#460](https://github.com/berkshelf/berkshelf/issues/460)
- h5 font size is too small on berkshelf.com [\#433](https://github.com/berkshelf/berkshelf/issues/433)
- Add link to berkshelf-shims [\#419](https://github.com/berkshelf/berkshelf/issues/419)
- Passing dependency resolution off to another tool? \(Librarian\) [\#396](https://github.com/berkshelf/berkshelf/issues/396)
- follow same convention as knife to find knife.rb [\#382](https://github.com/berkshelf/berkshelf/issues/382)
- Document SSL Issues [\#380](https://github.com/berkshelf/berkshelf/issues/380)
- add unrequested command [\#362](https://github.com/berkshelf/berkshelf/issues/362)
- Unable to activate activemodel-3.2.8 [\#290](https://github.com/berkshelf/berkshelf/issues/290)
- Cucumber test for skip-bundler option support check is mocked out [\#208](https://github.com/berkshelf/berkshelf/issues/208)

**Merged pull requests:**

- Re-think \#463? [\#472](https://github.com/berkshelf/berkshelf/pull/472) ([sethvargo](https://github.com/sethvargo))
- Fix the failing cucumber scenaiors [\#471](https://github.com/berkshelf/berkshelf/pull/471) ([sethvargo](https://github.com/sethvargo))
- Doc SSL issues - \#380 [\#470](https://github.com/berkshelf/berkshelf/pull/470) ([ivey](https://github.com/ivey))
- Init Error [\#468](https://github.com/berkshelf/berkshelf/pull/468) ([kbacha](https://github.com/kbacha))
- Update CLI example for 'berks cookbook'  [\#466](https://github.com/berkshelf/berkshelf/pull/466) ([jastix](https://github.com/jastix))
- Validate the shortname for 'site' [\#465](https://github.com/berkshelf/berkshelf/pull/465) ([capoferro](https://github.com/capoferro))
- Create Plugin List [\#459](https://github.com/berkshelf/berkshelf/pull/459) ([sethvargo](https://github.com/sethvargo))

## [v1.4.0](https://github.com/berkshelf/berkshelf/tree/v1.4.0) (2013-04-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.4.0.rc1...v1.4.0)

**Fixed bugs:**

- path source should expand from Berksfile location and now CWD [\#463](https://github.com/berkshelf/berkshelf/pull/463) ([reset](https://github.com/reset))

**Closed issues:**

- 1.4.0.rc1 - berks upload --freeze, thinks trying to upload cookbook named --freeze [\#447](https://github.com/berkshelf/berkshelf/issues/447)
- berks upload skips definitions [\#445](https://github.com/berkshelf/berkshelf/issues/445)
- Problems with Berkshelf and vagrant multi machine settings [\#441](https://github.com/berkshelf/berkshelf/issues/441)

**Merged pull requests:**

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

**Implemented enhancements:**

- Automatically freeze cookbooks on upload [\#431](https://github.com/berkshelf/berkshelf/pull/431) ([reset](https://github.com/reset))

**Fixed bugs:**

- Default locations are broken [\#399](https://github.com/berkshelf/berkshelf/issues/399)

**Closed issues:**

- Respect vagrant --no-provision [\#430](https://github.com/berkshelf/berkshelf/issues/430)
- Vagrant 1.1 Support [\#416](https://github.com/berkshelf/berkshelf/issues/416)
- Documentation should be updated [\#410](https://github.com/berkshelf/berkshelf/issues/410)
- Upload '--freeze' flag is not respected [\#320](https://github.com/berkshelf/berkshelf/issues/320)

**Merged pull requests:**

- add logging mixin and refactor Berkshelf.log into Berkshelf::Logger [\#434](https://github.com/berkshelf/berkshelf/pull/434) ([reset](https://github.com/reset))
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

**Closed issues:**

- Support for metadata.json fallback for non-existent metadata.rb [\#418](https://github.com/berkshelf/berkshelf/issues/418)
- Subcommand --help creates cookbook [\#411](https://github.com/berkshelf/berkshelf/issues/411)
- Upload fails with SignatureDoesNotMatch error [\#409](https://github.com/berkshelf/berkshelf/issues/409)
- Vagrant getting pinned [\#403](https://github.com/berkshelf/berkshelf/issues/403)
- Bump JSON dependency - Ruby 2.0 support [\#393](https://github.com/berkshelf/berkshelf/issues/393)
- Web site annoyance: Choppy Gutters [\#377](https://github.com/berkshelf/berkshelf/issues/377)
- Cookbook upload eating HTTP error messages [\#189](https://github.com/berkshelf/berkshelf/issues/189)

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

**Closed issues:**

- moneta/basic\_file missing [\#346](https://github.com/berkshelf/berkshelf/issues/346)

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

**Implemented enhancements:**

- remove dependency on Chef gem [\#342](https://github.com/berkshelf/berkshelf/pull/342) ([reset](https://github.com/reset))

**Fixed bugs:**

- hashie 2.0.0 throws an annoying warning [\#374](https://github.com/berkshelf/berkshelf/issues/374)
- default sources are broken [\#319](https://github.com/berkshelf/berkshelf/issues/319)
- `berks open` causing issues with my Vim config [\#259](https://github.com/berkshelf/berkshelf/issues/259)

**Closed issues:**

- "berks cookbook --help" creates a new cookbook named "--help" [\#373](https://github.com/berkshelf/berkshelf/issues/373)
- How to generate metadata.json ? [\#372](https://github.com/berkshelf/berkshelf/issues/372)
- Error running berks upload [\#370](https://github.com/berkshelf/berkshelf/issues/370)
- Broken berkshelf/vagrant integration [\#368](https://github.com/berkshelf/berkshelf/issues/368)
- chef attribute [\#353](https://github.com/berkshelf/berkshelf/issues/353)
- berkshelf 1.1.3 use in vagrant 1.0.6 broken because of chef 11.2.0 [\#341](https://github.com/berkshelf/berkshelf/issues/341)
- Segfault when running berks install in a vagrant [\#98](https://github.com/berkshelf/berkshelf/issues/98)

**Merged pull requests:**

- Autocreate git remotes [\#367](https://github.com/berkshelf/berkshelf/pull/367) ([capoferro](https://github.com/capoferro))
- Add debugging output [\#360](https://github.com/berkshelf/berkshelf/pull/360) ([sethvargo](https://github.com/sethvargo))
- Move vagrant development dependency to gemspec [\#356](https://github.com/berkshelf/berkshelf/pull/356) ([reset](https://github.com/reset))
- backout PR \#298 [\#355](https://github.com/berkshelf/berkshelf/pull/355) ([reset](https://github.com/reset))
- Git spec cleanup [\#352](https://github.com/berkshelf/berkshelf/pull/352) ([capoferro](https://github.com/capoferro))
- Remove unnecessary hard dependency on $HOME being set [\#340](https://github.com/berkshelf/berkshelf/pull/340) ([blasdelf](https://github.com/blasdelf))
- Bash completion for cookbooks [\#337](https://github.com/berkshelf/berkshelf/pull/337) ([sethvargo](https://github.com/sethvargo))
- Like bundler, berks should default do berks install [\#336](https://github.com/berkshelf/berkshelf/pull/336) ([sethvargo](https://github.com/sethvargo))
- Add Cane [\#333](https://github.com/berkshelf/berkshelf/pull/333) ([justincampbell](https://github.com/justincampbell))

## [v1.1.6](https://github.com/berkshelf/berkshelf/tree/v1.1.6) (2013-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.5...v1.1.6)

**Merged pull requests:**

- Move moneta from Gemfile to gemspec [\#350](https://github.com/berkshelf/berkshelf/pull/350) ([reset](https://github.com/reset))
- add vagrant to development and test gem group [\#344](https://github.com/berkshelf/berkshelf/pull/344) ([reset](https://github.com/reset))

## [v1.1.5](https://github.com/berkshelf/berkshelf/tree/v1.1.5) (2013-02-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.4...v1.1.5)

## [v1.1.4](https://github.com/berkshelf/berkshelf/tree/v1.1.4) (2013-02-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.3...v1.1.4)

**Fixed bugs:**

- Duplicated and unclear directions in Vagrantfile [\#330](https://github.com/berkshelf/berkshelf/issues/330)
- Incompatibility with Chef 11 beta client [\#306](https://github.com/berkshelf/berkshelf/issues/306)

**Closed issues:**

- 1-1 stable is missing things... [\#335](https://github.com/berkshelf/berkshelf/issues/335)
- `berks upload` for a non-existent cookbook does nothing... [\#332](https://github.com/berkshelf/berkshelf/issues/332)
- Verify Berkshelf on Rubygems.org [\#318](https://github.com/berkshelf/berkshelf/issues/318)

**Merged pull requests:**

- fix broken configure features [\#338](https://github.com/berkshelf/berkshelf/pull/338) ([reset](https://github.com/reset))
- Merge 1-1-stable into master [\#334](https://github.com/berkshelf/berkshelf/pull/334) ([justincampbell](https://github.com/justincampbell))
- Clarify language in Vagrantfile [\#331](https://github.com/berkshelf/berkshelf/pull/331) ([sethvargo](https://github.com/sethvargo))

## [v1.1.3](https://github.com/berkshelf/berkshelf/tree/v1.1.3) (2013-02-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.2...v1.1.3)

**Implemented enhancements:**

- Need a way to set maintainer info for skeleton cookbooks [\#313](https://github.com/berkshelf/berkshelf/issues/313)
- Support --quiet option [\#292](https://github.com/berkshelf/berkshelf/pull/292) ([sethvargo](https://github.com/sethvargo))

**Fixed bugs:**

- Installer/Updater are not thread safe [\#308](https://github.com/berkshelf/berkshelf/issues/308)
- Permission issues on cookbook install directory causes strange error [\#297](https://github.com/berkshelf/berkshelf/issues/297)
- Lockfile not getting updated [\#261](https://github.com/berkshelf/berkshelf/issues/261)
- Berkshelf has incompatible dependencies w/ Chef 10.16.2 [\#229](https://github.com/berkshelf/berkshelf/issues/229)

**Closed issues:**

- Vagrant ui deprecated and broken [\#312](https://github.com/berkshelf/berkshelf/issues/312)
- Add faraday as a dependency in gemspec [\#311](https://github.com/berkshelf/berkshelf/issues/311)
- Erlang Chef 11 compatibility [\#293](https://github.com/berkshelf/berkshelf/issues/293)
- Cookbook version installed is not determined by Berksfile.lock [\#289](https://github.com/berkshelf/berkshelf/issues/289)
- Add option to initialize cookbook with jenkins build support [\#272](https://github.com/berkshelf/berkshelf/issues/272)
- include vagrant-windows gem in Gemfile [\#221](https://github.com/berkshelf/berkshelf/issues/221)

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

## [v1.1.2](https://github.com/berkshelf/berkshelf/tree/v1.1.2) (2013-01-10)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.1...v1.1.2)

**Implemented enhancements:**

- Support path option for git sources [\#269](https://github.com/berkshelf/berkshelf/issues/269)
- option to skip syntax check on 'berks upload' [\#266](https://github.com/berkshelf/berkshelf/issues/266)

**Fixed bugs:**

- Actor shutdown messages are affecting json output [\#278](https://github.com/berkshelf/berkshelf/issues/278)

**Closed issues:**

- update documentation about :rel option for Github location  [\#286](https://github.com/berkshelf/berkshelf/issues/286)
- Cleanup branches [\#284](https://github.com/berkshelf/berkshelf/issues/284)
- add git\_collection source, or overload site: to work with cookbooks collections [\#88](https://github.com/berkshelf/berkshelf/issues/88)

**Merged pull requests:**

- Resolves issue \#286 [\#287](https://github.com/berkshelf/berkshelf/pull/287) ([arangamani](https://github.com/arangamani))
- Add development steps to CONTRIBUTING.md [\#280](https://github.com/berkshelf/berkshelf/pull/280) ([justincampbell](https://github.com/justincampbell))

## [v1.1.1](https://github.com/berkshelf/berkshelf/tree/v1.1.1) (2013-01-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.0...v1.1.1)

**Implemented enhancements:**

- git+ssh://host/path/to/repo "is not a valid Git URI" [\#257](https://github.com/berkshelf/berkshelf/issues/257)

**Closed issues:**

- Berks update does not update cookbook to latest version. [\#273](https://github.com/berkshelf/berkshelf/issues/273)
- Git dependencies of cookbooks not correctly resolved in main Berksfile [\#268](https://github.com/berkshelf/berkshelf/issues/268)
- created a wiki showing how to vendorize cookbooks [\#249](https://github.com/berkshelf/berkshelf/issues/249)
- `berks install --path blah` should honor .gitignore [\#248](https://github.com/berkshelf/berkshelf/issues/248)

**Merged pull requests:**

- Add option to skip ruby syntax check on upload [\#283](https://github.com/berkshelf/berkshelf/pull/283) ([reset](https://github.com/reset))
- fix our failing tests [\#282](https://github.com/berkshelf/berkshelf/pull/282) ([reset](https://github.com/reset))
- Add more files and patterns to chefignore. [\#281](https://github.com/berkshelf/berkshelf/pull/281) ([sethvargo](https://github.com/sethvargo))
- Add 'test/\*' to chefignore generator file. [\#279](https://github.com/berkshelf/berkshelf/pull/279) ([fnichol](https://github.com/fnichol))

## [v1.1.0](https://github.com/berkshelf/berkshelf/tree/v1.1.0) (2012-12-06)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.1.0.rc1...v1.1.0)

## [v1.1.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.1.0.rc1) (2012-11-30)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.4...v1.1.0.rc1)

**Implemented enhancements:**

- Feature Request: berks outdated [\#228](https://github.com/berkshelf/berkshelf/issues/228)
- Add option to freeze cookbooks on upload [\#122](https://github.com/berkshelf/berkshelf/issues/122)

**Fixed bugs:**

- Same cookbook can't be included in different groups [\#85](https://github.com/berkshelf/berkshelf/issues/85)

**Closed issues:**

- `berks update` should raise an error if given a cookbook that is not present in the Berksfile [\#247](https://github.com/berkshelf/berkshelf/issues/247)
- cannot download private cookbook from github repo using github: "org/repo" syntax [\#236](https://github.com/berkshelf/berkshelf/issues/236)
-  undefined method `load\_config' for Berkshelf:Module [\#233](https://github.com/berkshelf/berkshelf/issues/233)
- -o / --only  Not working as intended [\#232](https://github.com/berkshelf/berkshelf/issues/232)
- -o / --only  Not working as intended ? [\#231](https://github.com/berkshelf/berkshelf/issues/231)
- cookbooks\(filter\) fails to find "local" cookbooks [\#227](https://github.com/berkshelf/berkshelf/issues/227)
- `berks update` not updating... [\#220](https://github.com/berkshelf/berkshelf/issues/220)
- berks upload should allow the uploading of one cookbook [\#191](https://github.com/berkshelf/berkshelf/issues/191)
- cookbook update command [\#190](https://github.com/berkshelf/berkshelf/issues/190)

## [v1.0.4](https://github.com/berkshelf/berkshelf/tree/v1.0.4) (2012-11-16)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.3...v1.0.4)

## [v1.0.3](https://github.com/berkshelf/berkshelf/tree/v1.0.3) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.2...v1.0.3)

## [v1.0.2](https://github.com/berkshelf/berkshelf/tree/v1.0.2) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/berkshelf/berkshelf/tree/v1.0.1) (2012-11-14)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0...v1.0.1)

**Closed issues:**

- Git Not Found on Windows with msysgit [\#215](https://github.com/berkshelf/berkshelf/issues/215)

## [v1.0.0](https://github.com/berkshelf/berkshelf/tree/v1.0.0) (2012-11-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc3...v1.0.0)

**Implemented enhancements:**

- `berks version` runs extremely slowly [\#163](https://github.com/berkshelf/berkshelf/issues/163)
- Add github source [\#64](https://github.com/berkshelf/berkshelf/issues/64)

**Fixed bugs:**

- Should warn if using --foodcritic w/o thor-foodcritic installed [\#170](https://github.com/berkshelf/berkshelf/issues/170)
- `berks version` runs extremely slowly [\#163](https://github.com/berkshelf/berkshelf/issues/163)

**Closed issues:**

- Vendoring fails on Windows [\#209](https://github.com/berkshelf/berkshelf/issues/209)

## [v1.0.0.rc3](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc3) (2012-11-12)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc2...v1.0.0.rc3)

**Closed issues:**

- vagrant up issue if cookbook\_path is set by user and not an Array [\#194](https://github.com/berkshelf/berkshelf/issues/194)
- Vagrant Active Support issue ?  [\#193](https://github.com/berkshelf/berkshelf/issues/193)

## [v1.0.0.rc2](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc2) (2012-11-07)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v1.0.0.rc1...v1.0.0.rc2)

**Closed issues:**

- How do I wrap Berkshelf CLI ? [\#184](https://github.com/berkshelf/berkshelf/issues/184)

## [v1.0.0.rc1](https://github.com/berkshelf/berkshelf/tree/v1.0.0.rc1) (2012-11-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta4...v1.0.0.rc1)

**Closed issues:**

- Can you release 0.6.0-beta4, which has Windows bug fixes I need? [\#188](https://github.com/berkshelf/berkshelf/issues/188)

## [v0.6.0.beta4](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta4) (2012-11-01)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta3...v0.6.0.beta4)

**Implemented enhancements:**

- Should git initialization include a git commit? [\#181](https://github.com/berkshelf/berkshelf/issues/181)
- `berks init` should generate the same files as `berks cookbook create` [\#158](https://github.com/berkshelf/berkshelf/issues/158)

**Closed issues:**

- Access knife config in Berkshelf Thor task [\#185](https://github.com/berkshelf/berkshelf/issues/185)
- Unable to run berks install [\#177](https://github.com/berkshelf/berkshelf/issues/177)
- Detect when Cookbookfile has been changed and automatically update [\#46](https://github.com/berkshelf/berkshelf/issues/46)

## [v0.6.0.beta3](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta3) (2012-10-29)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta2...v0.6.0.beta3)

**Implemented enhancements:**

- Additional config options for `berks cookbook create` [\#151](https://github.com/berkshelf/berkshelf/issues/151)
- Vagrant plugin always tries to load Knife config [\#138](https://github.com/berkshelf/berkshelf/issues/138)

**Fixed bugs:**

- Vagrant Plugin Always Loads, Contradicts Documentation [\#161](https://github.com/berkshelf/berkshelf/issues/161)
- LoadError/json conflict [\#148](https://github.com/berkshelf/berkshelf/issues/148)
- Fails w/ call to mixlib-shellout/windows.rb on windows [\#146](https://github.com/berkshelf/berkshelf/issues/146)
- berks install error indicates wrong remote [\#145](https://github.com/berkshelf/berkshelf/issues/145)
- Dependency Resolution Broken on Windows 7 [\#140](https://github.com/berkshelf/berkshelf/issues/140)

**Closed issues:**

- vagrant plugin doesn't work when vagrant installed via vagrant omnibus installer [\#164](https://github.com/berkshelf/berkshelf/issues/164)
- Berkshelf only recursively pulling in dependencies defined in metadata.rb? [\#154](https://github.com/berkshelf/berkshelf/issues/154)
- Git and Vagrant should be the default during cookbook creation [\#152](https://github.com/berkshelf/berkshelf/issues/152)

## [v0.6.0.beta2](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta2) (2012-09-28)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.1...v0.6.0.beta2)

## [v0.5.1](https://github.com/berkshelf/berkshelf/tree/v0.5.1) (2012-09-28)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.6.0.beta1...v0.5.1)

**Fixed bugs:**

- Vagrant Plugin Fails When Upping \>1 VM [\#137](https://github.com/berkshelf/berkshelf/issues/137)

**Closed issues:**

- Cookbook 'application\_ruby' not found in any of the default locations [\#141](https://github.com/berkshelf/berkshelf/issues/141)
- Relax Chef version constraint to support Chef 10.14.x [\#139](https://github.com/berkshelf/berkshelf/issues/139)

## [v0.6.0.beta1](https://github.com/berkshelf/berkshelf/tree/v0.6.0.beta1) (2012-09-25)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0...v0.6.0.beta1)

## [v0.5.0](https://github.com/berkshelf/berkshelf/tree/v0.5.0) (2012-09-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc4...v0.5.0)

## [v0.5.0.rc4](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc4) (2012-09-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc3...v0.5.0.rc4)

## [v0.5.0.rc3](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc3) (2012-09-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc2...v0.5.0.rc3)

## [v0.5.0.rc2](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc2) (2012-09-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.5.0.rc1...v0.5.0.rc2)

## [v0.5.0.rc1](https://github.com/berkshelf/berkshelf/tree/v0.5.0.rc1) (2012-09-19)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0...v0.5.0.rc1)

**Implemented enhancements:**

- Add support for updating an individual cookbook via knife cookbook deps update COOKBOOK\_NAME [\#36](https://github.com/berkshelf/berkshelf/issues/36)

**Closed issues:**

- PROPOSAL: allow symlink option for :path cookbooks [\#96](https://github.com/berkshelf/berkshelf/issues/96)
- berks install --shims /tmp/cookbooks should detect new files [\#66](https://github.com/berkshelf/berkshelf/issues/66)

## [v0.4.0](https://github.com/berkshelf/berkshelf/tree/v0.4.0) (2012-09-11)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc4...v0.4.0)

**Implemented enhancements:**

- Provide a way to request 'recommends' dependencies [\#113](https://github.com/berkshelf/berkshelf/issues/113)

**Closed issues:**

- the --git option should populate w/ regexes to ignore temporary editor files [\#111](https://github.com/berkshelf/berkshelf/issues/111)
- knife plugin [\#82](https://github.com/berkshelf/berkshelf/issues/82)

## [v0.4.0.rc4](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc4) (2012-08-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc3...v0.4.0.rc4)

**Closed issues:**

- valid uri not passing validation [\#106](https://github.com/berkshelf/berkshelf/issues/106)

## [v0.4.0.rc3](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc3) (2012-08-20)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc2...v0.4.0.rc3)

**Implemented enhancements:**

- Add support for retrieving cookbooks from the local chef server configured in the knife config [\#37](https://github.com/berkshelf/berkshelf/issues/37)

**Closed issues:**

- add "addressable" as a development dependency [\#104](https://github.com/berkshelf/berkshelf/issues/104)
- Softlink in cookbook breaks berks install --shims [\#99](https://github.com/berkshelf/berkshelf/issues/99)
- Need override mechanism individual cookbooks in Berksfile [\#63](https://github.com/berkshelf/berkshelf/issues/63)

## [v0.4.0.rc2](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc2) (2012-07-27)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.4.0.rc1...v0.4.0.rc2)

**Implemented enhancements:**

- Add local chef server source [\#65](https://github.com/berkshelf/berkshelf/issues/65)

## [v0.4.0.rc1](https://github.com/berkshelf/berkshelf/tree/v0.4.0.rc1) (2012-07-13)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.7...v0.4.0.rc1)

**Fixed bugs:**

- Should allow shims directory to be in subdir of a cookbook using metadata [\#78](https://github.com/berkshelf/berkshelf/issues/78)

## [v0.3.7](https://github.com/berkshelf/berkshelf/tree/v0.3.7) (2012-07-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.6...v0.3.7)

## [v0.3.6](https://github.com/berkshelf/berkshelf/tree/v0.3.6) (2012-07-04)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.5...v0.3.6)

## [v0.3.5](https://github.com/berkshelf/berkshelf/tree/v0.3.5) (2012-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.4...v0.3.5)

## [v0.3.4](https://github.com/berkshelf/berkshelf/tree/v0.3.4) (2012-07-03)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.3...v0.3.4)

**Closed issues:**

- Warn if a :git entry points to a local path instead of a URL [\#70](https://github.com/berkshelf/berkshelf/issues/70)
- Berkshelf should not always require knife.rb [\#62](https://github.com/berkshelf/berkshelf/issues/62)

## [v0.3.3](https://github.com/berkshelf/berkshelf/tree/v0.3.3) (2012-06-27)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.2...v0.3.3)

## [v0.3.2](https://github.com/berkshelf/berkshelf/tree/v0.3.2) (2012-06-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.1...v0.3.2)

## [v0.3.1](https://github.com/berkshelf/berkshelf/tree/v0.3.1) (2012-06-26)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.3.0...v0.3.1)

## [v0.3.0](https://github.com/berkshelf/berkshelf/tree/v0.3.0) (2012-06-25)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.2.0...v0.3.0)

## [v0.2.0](https://github.com/berkshelf/berkshelf/tree/v0.2.0) (2012-06-24)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.5...v0.2.0)

## [v0.1.5](https://github.com/berkshelf/berkshelf/tree/v0.1.5) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.4...v0.1.5)

## [v0.1.4](https://github.com/berkshelf/berkshelf/tree/v0.1.4) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.3...v0.1.4)

## [v0.1.3](https://github.com/berkshelf/berkshelf/tree/v0.1.3) (2012-06-23)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.2...v0.1.3)

## [v0.1.2](https://github.com/berkshelf/berkshelf/tree/v0.1.2) (2012-06-22)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.1...v0.1.2)

## [v0.1.1](https://github.com/berkshelf/berkshelf/tree/v0.1.1) (2012-06-21)
[Full Changelog](https://github.com/berkshelf/berkshelf/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/berkshelf/berkshelf/tree/v0.1.0) (2012-06-21)
**Implemented enhancements:**

- Refactor Cookbook to multiple classes handling each installation path [\#35](https://github.com/berkshelf/berkshelf/issues/35)
- ambiguous error when cookbook not found [\#16](https://github.com/berkshelf/berkshelf/issues/16)
- path source should link, not copy, to the source [\#15](https://github.com/berkshelf/berkshelf/issues/15)

**Fixed bugs:**

- 404 Not found when installing a cookbook by path and a lockfile exists [\#14](https://github.com/berkshelf/berkshelf/issues/14)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
