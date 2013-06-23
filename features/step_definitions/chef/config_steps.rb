require 'tempfile'

Given /^I do not have a Chef config$/ do
  path   = Tempfile.new('chef_config').path
  config = Berkshelf::Chef::Config.from_file(path)
  config.save

  Berkshelf.chef_config = config

  ENV['BERKSHELF_CHEF_CONFIG'] = path
  set_env 'BERKSHELF_CHEF_CONFIG', path
end
