World(Berkshelf::RSpec::ChefAPI)

Given(/^the Chef Server is empty$/) do
  Berkshelf::RSpec::ChefServer.reset!
end

Given /^the Chef Server has cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    purge_cookbook(name, version)
    cb_path = generate_cookbook(tmp_path, name, version)
    upload_cookbook(cb_path, freeze: false, force: true)
  end
end

Given /^the Chef Server has frozen cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    purge_cookbook(name, version)
    cb_path = generate_cookbook(tmp_path, name, version)
    upload_cookbook(cb_path, freeze: true, force: true)
  end
 end

Then /^the Chef Server should have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(server_has_cookbook?(name, version)).to be_true
  end
end

Then /^the Chef Server should not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(server_has_cookbook?(name, version)).to be_false
  end
end

Then(/^the version locks in the "(.*?)" environment should be:$/) do |environment_name, version_locks|
  environment_cookbook_versions = environment(environment_name).cookbook_versions
  version_locks.hashes.each do |hash|
    expect(environment_cookbook_versions[hash['cookbook']]).to eq(hash['version_lock'])
  end
end

Given(/^The Chef Server has an environment named "(.*?)"$/) do |environment_name|
  delete_environment(environment_name)
  begin
    create_environment(environment_name)
  rescue Ridley::Errors::HTTPConflict; end
end

Given(/^The Chef Server does not have an environment named "(.*?)"$/) do |environment_name|
  if environment_exists?(environment_name)
    delete_environment(environment_name)
  end
end
