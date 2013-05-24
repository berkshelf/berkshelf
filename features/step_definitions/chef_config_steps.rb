Given /^I have a default Chef config file$/ do
  path = File.join(tmp_path, 'knife.rb')
  Berkshelf.chef_config = Berkshelf::Chef::Config.new(path)
  Berkshelf.chef_config.save

  set_env('BERKSHELF_CHEF_CONFIG', path)
end
