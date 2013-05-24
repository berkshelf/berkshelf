Given /^I have a default Chef config$/ do
  Berkshelf.chef_config = Berkshelf::Chef::Config.new
end
