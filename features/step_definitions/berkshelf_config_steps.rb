Given /^I have a default Berkshelf config file$/ do
  Berkshelf::Config.new.save
end

Given /^I have a Berkshelf config file containing:$/ do |contents|
  path = File.join(tmp_path, 'config.json')
  File.open(path, 'w+') { |f| f.write(contents) }
  Berkshelf::Config.path = path
end

Given /^I do not have a Berkshelf config file$/ do
  Berkshelf::Config.instance_variable_set(:@instance, nil)
  remove_file(Berkshelf::Config.path) if File.exists?(Berkshelf::Config.path)
end

Given /^I do not have a Berkshelf config file at "(.+)"$/ do |path|
  if File.exists?(path)
    remove_file(path)
    Berkshelf::Config.instance_variable_set(:@instance, nil)
  end
end
