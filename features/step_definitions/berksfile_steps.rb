Given /^a Berksfile with path location sources to fixtures:$/ do |cookbooks|
  lines = []
  cookbooks.raw.each do |name, fixture|
    fixture_path = fixtures_path.join("cookbooks", fixture)
    lines << "cookbook '#{name}', path: '#{fixture_path}'"
  end
  write_file("Berksfile", lines.join("\n"))
end
