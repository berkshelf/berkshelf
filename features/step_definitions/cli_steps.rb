Then /^the exit status should be "(.+)"$/ do |name|
  code = Berkshelf.const_get(name).status_code
  assert_exit_status(code)
end
