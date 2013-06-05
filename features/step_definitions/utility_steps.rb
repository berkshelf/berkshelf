Given /^pending\s+"([^\"]+)"$/ do |msg|
  pending
end

Given(/^the BERKSHELF_EDITOR and VISUAL environment variables are not set$/) do
  set_env "BERKSHELF_EDITOR", nil
  set_env "VISUAL", nil
end

Given /^the environment variable (.+) is nil$/ do |variable|
  set_env variable, nil
end

Given /^the environment variable (.+) is "(.+)"$/ do |variable, value|
  set_env variable, value
end

Then /^the output should be the same as \`(.+)\`$/ do |command|
  run_simple(command)
  output = output_from(command)
  expect(all_output).to include(output)
end

# The built-in regex matcher does not support multi-line matching :(
Then /^the output should match multiline:$/ do |expected|
  regex = Regexp.new(expected.strip, Regexp::MULTILINE)
  expect(regex).to match(all_output)
end
