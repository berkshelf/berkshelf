require 'aruba/api'

World(Aruba::Api)

Given /^a cookbook named "(.*?)"$/ do |name|
  steps %{
    Given a directory named "#{name}"
    And an empty file named "#{name}/metadata.rb"
  }
end

Then /^the cookbook "(.*?)" should have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| File.join(name, file_row[0])}, true)
end

Then /^the file "(.*?)" in the cookbook "(.*?)" should contain:$/ do |file_name, cookbook_name, content|
  Pathname.new(current_dir).join(cookbook_name).should have_structure {
    file "Cookbookfile" do
      contains content
    end
    file ".chefignore"
  }
end

Then /^the directory "(.*?)" should have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| File.join(name, file_row[0])}, true)
end

Then /^the directory "(.*?)" should not have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| File.join(name, file_row[0])}, false)
end

Then /^the file "(.*?)" in the directory "(.*?)" should not contain:$/ do |file_name, directory_name, content|
  Pathname.new(current_dir).join(directory_name).should_not have_structure {
    file "Cookbookfile" do
      contains content
    end
  }
end

Then /^the current directory should have the following files:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, true)
end

Then /^the current directory should not have the following files:$/ do |files|
  check_file_presence(files.raw.map{|file_row| file_row[0]}, false)
end
