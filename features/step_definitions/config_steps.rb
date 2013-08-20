require 'tempfile'

Given /^I already have a Berkshelf config file$/ do
  path   = Tempfile.new('berkshelf').path
  config = Berkshelf::Config.new(path)
  config.save

  Berkshelf.config = config

  ENV['BERKSHELF_CONFIG'] = path
  set_env 'BERKSHELF_CONFIG', path
end

Given /^I have a Berkshelf config file containing:$/ do |contents|
  path = Berkshelf.config.path
  FileUtils.mkdir_p(Pathname.new(path).dirname.to_s)

  File.open(path, 'w+') { |f| f.write(contents) }

  Berkshelf.config = Berkshelf::Config.from_file(path)
end

Then /^a Berkshelf config file should exist and contain:$/ do |table|
  # Have to reload the config...
  Berkshelf.config.reload

  check_file_presence([Berkshelf.config.path], true)

  table.raw.each do |key, value|
    if value == "BOOLEAN[true]"
      value = true
    end
    expect(Berkshelf.config[key]).to eq(value)
  end
end

Then /^a Berkshelf config file should exist at "(.+)" and contain:$/ do |path, table|
  check_file_presence([path], true)

  path             = File.join(@dirs.first, path)
  Berkshelf.config = Berkshelf::Config.from_file(path)

  table.raw.each do |key, value|
    expect(Berkshelf.config[key]).to eq(value)
  end
end
