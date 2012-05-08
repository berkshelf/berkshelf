guard 'spork' do
  watch('Gemfile')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{^spec/support/}) { :rspec }
  watch(%r{^features/support/}) { :cucumber }
end

guard 'rspec', :version => 2, :cli => "--color --drb --format Fuubar", :all_on_start => false, :all_after_pass => false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/tryhard/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
end
