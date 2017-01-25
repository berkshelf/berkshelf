Then /^the exit status should be "(.+)"$/ do |name|
  error = name.split("::").reduce(Berkshelf) { |klass, id| klass.const_get(id) }
  expect(last_command_started).to have_exit_status(error.status_code)
end

Then /^the results should have the cookbooks:$/ do |cookbooks|
  list = last_command_started.stdout
  cookbooks.split("\n").each do |cookbook|
    expect(list).to include(cookbook)
  end
end

Then /^the results should each start with "(.+)"$/ do |prefix|
  list = last_command_started.stdout
  list.split("\n").each do |cookbook|
    expect(cookbook).to start_with(prefix)
  end
end
