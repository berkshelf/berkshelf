require 'aruba/api'

World(Aruba::Api)
World(Berkshelf::RSpec::ChefAPI)

Given /^I dynamically write to "(.+)" with:$/ do |file, contents|
  steps %{
    Given I write to "#{file}" with:
      """
      #{ERB.new(contents).result(binding)}
      """
  }
end

Given /^a cookbook named "(.*?)"$/ do |name|
  steps %{
    Given a directory named "#{name}"
    And an empty file named "#{name}/metadata.rb"
  }
end

Given /^I do not have a Berksfile$/ do
  in_current_dir { FileUtils.rm_f(Berkshelf::DEFAULT_FILENAME) }
end

Given /^I do not have a Berksfile\.lock$/ do
  in_current_dir { FileUtils.rm_f("#{Berkshelf::DEFAULT_FILENAME}.lock") }
end

Given /^I have a default Berkshelf config file$/ do
  Berkshelf::Config.new.save
end

Given /^I have a Berkshelf config file containing:$/ do |contents|
  ::File.open(Berkshelf::Config.path, 'w+') do |f|
    f.write(contents)
  end
end

Given /^I do not have a Berkshelf config file$/ do
  remove_file Berkshelf::Config.path if ::File.exists? Berkshelf::Config.path
end

Given /^I do not have a Berkshelf config file at "(.+)"$/ do |path|
  remove_file(path) if File.exists?(path)
end


Given /^the cookbook "(.*?)" has the file "(.*?)" with:$/ do |cookbook_name, file_name, content|
  write_file(::File.join(cookbook_name, file_name), content)
end

Given /^the cookbook store has the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version, license|
    generate_cookbook(cookbook_store, name, version, license: license)
  end
end

Given /^the cookbook store has the cookbooks installed by git:$/ do |cookbooks|
  cookbooks.raw.each do |name, version, sha|
    folder   = "#{name}-#{sha}"
    metadata = File.join(folder, 'metadata.rb')

    create_dir(folder)
    write_file(metadata, [
      "name '#{name}'",
      "version '#{version}'"
    ].join("\n"))
  end
end

Given /^the cookbook store contains a cookbook "(.*?)" "(.*?)" with dependencies:$/ do |name, version, dependencies|
  generate_cookbook(cookbook_store, name, version, dependencies: dependencies.raw)
end

Then /^the cookbook store should have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(cookbook_store).to have_structure {
      directory "#{name}-#{version}" do
        file "metadata.rb" do
          contains version
        end
      end
    }
  end
end

Then /^the cookbook store should have the cookbooks installed by git:$/ do |cookbooks|
  cookbooks.raw.each do |name, version, sha1|
    expect(cookbook_store).to have_structure {
      directory "#{name}-#{sha1}" do
        file "metadata.rb" do
          contains version
        end
      end
    }
  end
end

Then /^the cookbook store should not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(cookbook_store).to_not have_structure {
      directory "#{name}-#{version}"
    }
  end
end

Then /^I should have the cookbook "(.*?)"$/ do |name|
  expect(Pathname.new(current_dir).join(name)).to be_cookbook
end

Then /^I should have a new cookbook skeleton "(.*?)"$/ do |name|
  cb_path = Pathname.new(current_dir).join(name)
  expect(cb_path).to have_structure {
    directory "attributes"
    directory "definitions"
    directory "files" do
      directory "default"
    end
    directory "libraries"
    directory "providers"
    directory "recipes" do
      file "default.rb"
    end
    directory "resources"
    directory "templates" do
      directory "default"
    end
    file ".gitignore"
    file "chefignore"
    file "Berksfile" do
      contains "metadata"
    end
    file "Gemfile" do
      contains "gem 'berkshelf'"
    end
    file "metadata.rb"
    file "README.md"
    file "Vagrantfile" do
      contains "recipe[#{name}::default]"
    end
  }
end

Then /^I should have a new cookbook skeleton "(.*?)" with Chef-Minitest support$/ do |name|
  steps %Q{ Then I should have a new cookbook skeleton "#{name}" }

  cb_path = Pathname.new(current_dir).join(name)
  expect(cb_path).to have_structure {
    file "Berksfile" do
      contains "cookbook 'minitest-handler'"
    end
    file "Vagrantfile" do
      contains "recipe[minitest-handler::default]"
    end
    directory "files" do
      directory "default" do
        directory "tests" do
          directory "minitest" do
            file "default_test.rb" do
              contains "describe '#{name}::default' do"
              contains "include Helpers::#{name.capitalize}"
            end
            directory "support" do
              file "helpers.rb" do
                contains "module #{name.capitalize}"
              end
            end
          end
        end
      end
    end
  }
end


Then /^I should have a new cookbook skeleton "(.*?)" with Foodcritic support$/ do |name|
  steps %Q{ Then I should have a new cookbook skeleton "#{name}" }

  cb_path = Pathname.new(current_dir).join(name)
  expect(cb_path).to have_structure {
    file "Gemfile" do
      contains "gem 'thor-foodcritic'"
    end
    file "Thorfile" do
      contains "require 'thor/foodcritic'"
    end
  }
end

Then /^I should have a new cookbook skeleton "(.*?)" with SCMVersion support$/ do |name|
  steps %Q{ Then I should have a new cookbook skeleton "#{name}" }

  cb_path = Pathname.new(current_dir).join(name)
  expect(cb_path).to have_structure {
    file "Gemfile" do
      contains "gem 'thor-scmversion'"
    end
    file "Thorfile" do
      contains "require 'thor/scmversion'"
    end
  }
end

Then /^I should have a new cookbook skeleton "(.*?)" with no Bundler support$/ do |name|
  cb_path = Pathname.new(current_dir).join(name)
  expect(cb_path).to have_structure {
    directory "attributes"
    directory "definitions"
    directory "files" do
      directory "default"
    end
    directory "libraries"
    directory "providers"
    directory "recipes" do
      file "default.rb"
    end
    directory "resources"
    directory "templates" do
      directory "default"
    end
    file "README.md"
    file "metadata.rb"
    file "Berksfile" do
      contains "metadata"
    end
    file "chefignore"
    file "Berksfile"
    no_file "Gemfile"
  }
end

Then /^I should have a new cookbook skeleton "(.*?)" with no Git support$/ do |name|
  expect(Pathname.new(current_dir).join(name)).to have_structure {
    no_file ".gitignore"
  }
end

Then /^I should have a new cookbook skeleton "(.*?)" with no Vagrant support$/ do |name|
  expect(Pathname.new(current_dir).join(name)).to have_structure {
    file "Gemfile" do
      does_not_contain "gem 'vagrant'"
    end
    no_file "Vagrantfile"
  }
end

Then /^the cookbook "(.*?)" should have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| ::File.join(name, file_row[0])}, true)
end

Then /^the cookbook "(.*?)" should not have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| ::File.join(name, file_row[0])}, false)
end

Then /^the file "(.*?)" in the cookbook "(.*?)" should contain:$/ do |file_name, cookbook_name, content|
  expect(Pathname.new(current_dir).join(cookbook_name)).to have_structure {
    file "Berksfile" do
      contains content
    end
    file "chefignore"
  }
end

Then /^the resulting "(.+)" Vagrantfile should contain:$/ do |cookbook_name, content|
  expect(Pathname.new(current_dir).join(cookbook_name)).to have_structure {
    file "Vagrantfile" do
      content.respond_to?(:raw) ?
        content.raw.flatten.each { |string| contains string } :
        contains(content)
    end
  }
end

Then /^the directory "(.*?)" should have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| ::File.join(name, file_row[0])}, true)
end

Then /^the directory "(.*?)" should not have the following files:$/ do |name, files|
  check_file_presence(files.raw.map{|file_row| ::File.join(name, file_row[0])}, false)
end

Then /^the file "(.*?)" in the directory "(.*?)" should not contain:$/ do |file_name, directory_name, content|
  Pathname.new(current_dir).join(directory_name).should_not have_structure {
    file "Berksfile" do
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
