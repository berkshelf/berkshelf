require 'aruba/api'

World(Aruba::Api)
World(KnifeCookbookDependencies::RSpec::FileSystemMatchers)

Then /^I trace$/ do
end

When /^I sleep$/ do
  sleep 10
end

Then /^a file named "(.*?)" should exist in the current directory$/ do |filename|
  in_current_dir do
    File.exists?(filename).should be_true # not sure why Aruba's
                                          # #check_file_presence
                                          # doesn't work here. It
                                          # looks in the wrong
                                          # directory.
  end
end

Then /^the file "(.*?)" should contain in the current directory:$/ do |filename, string|
  in_current_dir do
    File.read(filename).should match(Regexp.new(string))
  end
end

Then /^the temp directory should not exist$/ do
  File.exists?(KCD::TMP_DIRECTORY).should be_false
end

When /^I run the init command with the cookbook "(.*?)" as the target$/ do |cookbook_name|
  run_simple(unescape("knife cookbook dependencies init #{cookbook_name}"))
end

When /^I run the init command with the directory "(.*?)" as the target$/ do |directory_name|
  run_simple(unescape("knife cookbook dependencies init #{directory_name}"))
end

When /^I run the init command with a path that has already been initialized as the target$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I run the init command with no value for the target$/ do
  run_simple(unescape("knife cookbook dependencies init"))
end

When /^I run the install command$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the install should successfully run$/ do
  pending # express the regexp above with the code you wish you had
end
