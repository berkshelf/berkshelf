Given(/^I do not have a Berkshelf config$/) do
  FileUtils.rm_f(ENV['BERKSHELF_CONFIG'])
end

Given /^I do not have a Chef config$/ do
  path = tmp_path.join('knife.rb').to_s
  Berkshelf.chef_config = Ridley::Chef::Config.new(path)
  Berkshelf.chef_config.save

  ENV['BERKSHELF_CHEF_CONFIG'] = path
  set_env 'BERKSHELF_CHEF_CONFIG', path
end
