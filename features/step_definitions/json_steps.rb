Then /^the output should be JSON$/ do
  lambda { parse_json(all_output) }.should_not raise_error
end
