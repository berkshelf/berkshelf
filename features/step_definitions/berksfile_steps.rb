Given /^a Berksfile with path location sources to fixtures:$/ do |cookbooks|
  lines = []
  cookbooks.raw.each do |name, fixture|
    fixture_path = File.join(fixtures_path, 'cookbooks', fixture)
    lines << "cookbook '#{name}', path: '#{fixture_path}'"
  end
  write_file('Berksfile', lines.join("\n"))
end

Given /^I do not have a Berksfile$/ do
  in_current_dir { FileUtils.rm_f(Berkshelf::DEFAULT_FILENAME) }
end

Given /^I do not have a Berksfile\.lock$/ do
  in_current_dir { FileUtils.rm_f("#{Berkshelf::DEFAULT_FILENAME}.lock") }
end
