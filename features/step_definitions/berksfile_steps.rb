Given /I have a Berksfile pointing at the community API endpoint with:/ do |contents|
  contents = "source '#{Berkshelf::Berksfile::DEFAULT_API_URL}'\n\n" + contents
  write_file('Berksfile', contents)
end
