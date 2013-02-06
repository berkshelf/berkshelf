Then /^the output should be JSON$/ do
  lambda { parse_json(all_output) }.should_not raise_error
end

Then /^the file "(.*?)" should contain JSON:$/ do |file, data|
  target = MultiJson.decode(data)
  actual = MultiJson.decode(File.read(File.join(current_dir, file)))

  target.should eql(actual)
end
