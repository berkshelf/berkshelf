Then /^a Berkshelf config file should exist and contain:$/ do |table|
  config = Berkshelf::Config.from_file(Berkshelf::Config.path)
  table.raw.each do |key, value|
    config.get_attribute(key).should eql(value)
  end
end
