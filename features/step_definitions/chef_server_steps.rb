World(KCD::RSpec::ChefAPI)

Given /^the Chef server does not have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    purge_cookbook(name, version)
  end
end

Then /^the Chef server should have the cookbooks:$/ do |cookbooks|
  cookbooks.raw.each do |name, version|
    server_has_cookbook?(name, version).should be_true
  end
end
