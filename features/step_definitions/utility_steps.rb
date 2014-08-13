Given /^skip\s+"([^\"]+)"$/ do |msg|
  skip
end

Then /the output from \`(.+)\` should be the same as \`(.+)\`/ do |actual, expected|
  run_simple(actual)
  run_simple(expected)
  expect(output_from(actual)).to eq(output_from(expected))
end
