Given /^I have a default Chef config$/ do
  STDOUT.puts "Standard Chef Config"
  path = tmp_path.join('knife.rb').to_s
  generate_chef_config(path)

  Berkshelf::Chef::Config.from_file(path)
end
