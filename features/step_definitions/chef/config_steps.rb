Given(/^I do not have a Berkshelf config$/) do
  FileUtils.rm_f(ENV['BERKSHELF_CONFIG'])
end

Given /^I do not have a Chef config$/ do
	path = tmp_path.join('knife.rb').to_s
  Berkshelf.chef_config = Berkshelf::Chef::Config.new(path)
  Berkshelf::Chef::Config.instance.save

  ENV['BERKSHELF_CHEF_CONFIG'] = path
  set_env 'BERKSHELF_CHEF_CONFIG', path
end
