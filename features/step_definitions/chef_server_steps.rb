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
    server_has_cookbook?(name, version).should be_true
  end
end

Then /^the Chef server should not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    server_has_cookbook?(name, version).should be_false
  end
end
