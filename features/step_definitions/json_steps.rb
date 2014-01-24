class Hash
  def sort_by_key(&block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if seed[key].is_a?(Hash)
        seed[key] = seed[key].sort_by_key(&block)
      elsif seed[key].is_a?(Array)
        seed[key] = seed[key].map do |i|
          i.respond_to?(:sort_by_key) ? i.sort_by_key(&block) : i
        end
      end
      seed
    end
  end
end

Then /^the output should contain JSON:$/ do |data|
  target = JSON.pretty_generate(JSON.parse(data).sort_by_key)
  actual = JSON.pretty_generate(JSON.parse(all_output).sort_by_key)

  expect(actual).to eq(target)
end
