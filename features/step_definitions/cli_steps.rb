require 'aruba/api'

World(Aruba::Api)

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
