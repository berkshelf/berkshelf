World(Berkshelf::RSpec::ChefServer)

Given(/^the Chef Server is empty$/) do
  Berkshelf::RSpec::ChefServer.reset!
end

Given /^the Chef Server has cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version, dependencies|
    metadata = []
    metadata << "name '#{name}'"
    metadata << "version '#{version}'"
    dependencies.to_s.split(',').map { |d| d.split(' ', 2) }.each do |(name, constraint)|
      metadata << "depends '#{name}', '#{constraint}'"
    end

    chef_cookbook(name, { 'metadata.rb' => metadata.join("\n") })
  end
end

Given /^the Chef Server has frozen cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    chef_cookbook(name, { 'metadata.rb' => "version '#{version}'", frozen: true })
  end
end

Given(/^the Chef Server has an environment named "(.*?)"$/) do |name|
  chef_environment(name, { 'description' => 'This is an environment' })
end

Given(/^the Chef Server does not have an environment named "(.*?)"$/) do |name|
  if chef_server.data_store.exists?(['environments', name])
    chef_server.data_store.delete(['environments', name])
  end
end

Then /^the Chef Server should have the cookbooks:$/ do |cookbooks|
  list = chef_cookbooks
  cookbooks.raw.each do |name, version|
    expect(list.keys).to  include(name)
    expect(list[name]).to include(version) unless version.nil?
  end
end

Then /^the Chef Server should not have the cookbooks:$/ do |cookbooks|
  list = chef_cookbooks
  cookbooks.raw.each do |name, version|
    unless version.nil?
      expect(list.keys).to_not include(name)
    else
      expect(list[name] || []).to_not include(version)
    end
  end
end

Then(/^the version locks in the "(.*?)" environment should be:$/) do |name, locks|
  list = chef_environment_locks(name)
  locks.raw.each do |cookbook, version|
    expect(list[cookbook]).to eq(version)
  end
end
