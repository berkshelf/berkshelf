Given /^pending\s+"([^\"]+)"$/ do |msg|
  pending
end

Then /^the output should be the same as \`(.+)\`$/ do |command|
  run_simple(command)
  output = output_from(command)
  expect(all_output).to include(output)
end
