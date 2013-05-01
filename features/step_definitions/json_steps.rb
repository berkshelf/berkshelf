class Hash
  def sort_by_key(&block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      seed[key] = seed[key].sort_by_key(&block) if seed[key].is_a?(Hash)
      seed
    end
  end
end

Then /^the output should be JSON$/ do
  lambda { parse_json(all_output) }.should_not raise_error
end

Then /^the file "(.*?)" should contain JSON:$/ do |file, data|
  target = MultiJson.encode(MultiJson.decode(data).sort_by_key, pretty: true)
  actual = MultiJson.encode(MultiJson.decode(File.read(File.join(current_dir, file))).sort_by_key, pretty: true)

  expect(actual).to eq(target)
end
