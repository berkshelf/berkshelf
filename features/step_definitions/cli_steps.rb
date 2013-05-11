require 'aruba/api'

World(Aruba::Api)
World(Berkshelf::RSpec::FileSystemMatchers)

Then /^I trace$/ do
end

When /^I sleep$/ do
  sleep 10
end

Then /^a file named "(.*?)" should exist in the current directory$/ do |filename|
  in_current_dir do
    expect(File.exists?(filename)).to be_true # not sure why Aruba's
                                          # #check_file_presence
                                          # doesn't work here. It
                                          # looks in the wrong
                                          # directory.
  end
end

Then /^the file "(.*?)" should contain in the current directory:$/ do |filename, string|
  in_current_dir do
    expect(File.read(filename)).to match(Regexp.new(string))
  end
end

When /^I run the init command with the cookbook "(.*?)" as the target$/ do |cookbook_name|
  run_simple(unescape("berks init #{cookbook_name}"), true)
end

When /^I run the init command with the directory "(.*?)" as the target$/ do |directory_name|
  run_simple(unescape("berks init #{directory_name}"), true)
end

When /^I run the init command with no value for the target$/ do
  run_simple(unescape("berks init"), true)
end

When /^I run the install command$/ do
  run_simple(unescape("berks install"), false)
end

When /^I run the install command with flags:$/ do |flags|
  run_simple(unescape("berks install #{flags.raw.join(" ")}"), false)
end

When /^I run the upload command$/ do
  run_simple(unescape("berks upload"), true)
end

When /^I run the upload command with flags:$/ do |flags|
  run_simple(unescape("berks upload #{flags.raw.join(" ")}"), false)
end

When /^I run the cookbook command to create "(.*?)"$/ do |name|
  run_simple(unescape("berks cookbook #{name}"), false)
end

When /^I (successfully )?run the apply command on "(.*?)"$/ do |successfully, environment_name|
  run_simple(unescape("berks apply #{environment_name}"), !!successfully)
end

When /^I (successfully )?run the apply command on "(.*?)" with flags:$/ do |successfully, environment_name, flags|
  run_simple(unescape("berks apply #{environment_name} #{flags.raw.join(" ")}"), !!successfully)
end

When /^I run the cookbook command to create "(.*?)" with options:$/ do |name, options|
  run_simple(unescape("berks cookbook #{name} #{options.raw.join(" ")}"))
end

When /^I run the "(.*?)" command interactively$/ do |command|
  run_interactive("berks #{command}")
end

Then /^the CLI should exit with the status code for error "(.*?)"$/ do |error_constant|
  exit_status = Berkshelf.const_get(error_constant).status_code
  assert_exit_status(exit_status)
end
