class Hash
  def sort_by_key(&block)
    keys.sort(&block).reduce({}) do |seed, key|
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

# Pending Ridley allowing newer Faraday and Celluloid.
def clean_json_output(output)
  output.gsub(/^.+warning: constant ::Fixnum is deprecated$/, "") \
        .gsub(/^.*forwarding to private method Celluloid::PoolManager#url_prefix$/, "")
end

Then /^the output should contain JSON:$/ do |data|
  parsed = ERB.new(data).result
  target = JSON.pretty_generate(JSON.parse(parsed).sort_by_key)
  actual = JSON.pretty_generate(JSON.parse(all_commands.map { |c| clean_json_output(c.output) }.join("\n")).sort_by_key)

  expect(actual).to eq(target)
end
