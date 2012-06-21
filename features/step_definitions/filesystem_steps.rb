require 'aruba/api'

World(Aruba::Api)

Given /^a cookbook named "(.*?)"$/ do |name|
  steps %{
    Given a directory named "#{name}"
    And an empty file named "#{name}/metadata.rb"
  }
end

Given /^I do not have a Cookbookfile$/ do
  in_current_dir { FileUtils.rm_f(Berkshelf::DEFAULT_FILENAME) }
end

Given /^I do not have a Cookbookfile\.lock$/ do
  in_current_dir { FileUtils.rm_f(Berkshelf::Lockfile::DEFAULT_FILENAME) }
end

Given /^the cookbook "(.*?)" has the file "(.*?)" with:$/ do |cookbook_name, file_name, content|
  write_file(File.join(cookbook_name, file_name), content)
end

Then /^the cookbook store should have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    cookbook_store.should have_structure {
      directory "#{name}-#{version}" do
        file "metadata.rb" do
          contains version
        end
      end
    }
  end
end

Then /^the cookbook store should not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    cookbook_store.should_not have_structure {
      directory "#{name}-#{version}"
    }
  end
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
