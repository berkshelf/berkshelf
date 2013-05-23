Given /^I have the default Chef config$/ do
  path = File.join('spec', 'config', 'knife.rb').to_s
  contents = [
    'chef_server_url          "http://localhost:4000"',
    'validation_key           "/etc/chef/validation.pem"',
    'validation_client_name   "chef-validator"',
    'client_key               "/etc/chef/client.pem"'
  ].join("\n")

  File.open(path, 'w+') { |f| f.write(contents) }

  Berkshelf::Chef::Config.from_file(path)
end

Given /^I do not have a Chef config$/ do
  remove_file(Berkshelf::Chef::Config.path) if File.exists?(Berkshelf::Chef::Config.path)
  Berkshelf::Chef::Config.instance_variable_set(:@instance, nil)
end
