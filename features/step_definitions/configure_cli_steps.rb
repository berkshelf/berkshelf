Given /^I have a default Chef config$/ do
  path = tmp_path.join('chef_config').to_s
  generate_chef_config(path)
  ENV['BERKSHELF_CHEF_CONFIG'] = path
end

Then /^a Berkshelf config file should exist and contain:$/ do |table|
  config = Berkshelf::Config.from_file(Berkshelf::Config.path)
  table.raw.each do |key, value|
    expect(config.get_attribute(key)).to eq(value)
  end
end

Then /^a Berkshelf config file should exist at "(.+)" and contain:$/ do |path, table|
  config = Berkshelf::Config.from_file(File.expand_path("tmp/aruba/#{path}"))
  table.raw.each do |key, value|
    config.get_attribute(key).should eql(value)
  end
end
