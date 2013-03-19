Given /^pending\s+"([^\"]+)"$/ do |msg|
  pending
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