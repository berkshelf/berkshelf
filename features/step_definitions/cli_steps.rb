Then /^the exit status should be "(.+)"$/ do |name|
  error = name.split('::').reduce(Berkshelf) { |klass, id| klass.const_get(id) }
  assert_exit_status(error.status_code)
end
