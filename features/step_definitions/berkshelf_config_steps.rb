Given /^I have a default Berkshelf config file$/ do
  Berkshelf::Config.new.save
end

Given /^I have a Berkshelf config file containing:$/ do |contents|
  path = File.join(berkshelf_path, 'config.json')
  File.open(path, 'w+') { |f| f.write(contents) }
  Berkshelf::Config.path = path
  Berkshelf::Config.reload
end

Given /^I do not have a Berkshelf config file$/ do
  path = File.join(berkshelf_path, 'config.json')

  remove_file(Berkshelf::Config.path) if File.exists?(Berkshelf::Config.path)
  remove_file(path) if File.exists?(path)

  Berkshelf::Config.path = path
  Berkshelf::Config.reload
end

Given /^I do not have a Berkshelf config file at "(.+)"$/ do |path|
  remove_file(path) if File.exists?(path)
  Berkshelf::Config.reload
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
