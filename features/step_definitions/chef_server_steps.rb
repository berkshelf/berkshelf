World(Berkshelf::RSpec::ChefAPI)

Given /^the Chef server does not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    purge_cookbook(name, version)
  end
end

Given /^the Chef server has cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    purge_cookbook(name, version)
    cb_path = generate_cookbook(tmp_path, name, version)
    upload_cookbook(cb_path)
  end
end

Then /^the Chef server should have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(server_has_cookbook?(name, version)).to be_true
  end
end

Then /^the Chef server should not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    expect(server_has_cookbook?(name, version)).to be_false
  end
end

Given(/^I have an environment named "(.*?)"$/) do |environment_name|
  delete_environment(environment_name)
  begin
    create_environment(environment_name)
  rescue Ridley::Errors::HTTPConflict; end
end

Then(/^the version locks in "(.*?)" should be:$/) do |environment_name, version_locks|
  environment_cookbook_versions = environment(environment_name).cookbook_versions
  version_locks.hashes.each do |hash|
    expect(environment_cookbook_versions[hash['cookbook']]).to eq(hash['version_lock'])
  end
end

Given(/^I do not have an environment named "(.*?)"$/) do |environment_name|
  delete_environment(environment_name) if environment_exists? environment_name
end
