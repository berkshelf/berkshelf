Then /^the exit status should be "(.+)"$/ do |name|
  error = name.split('::').reduce(Berkshelf) { |klass, id| klass.const_get(id) }
  expect(last_command_started).to have_exit_status(error.status_code)
end
