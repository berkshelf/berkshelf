guard 'spork' do
  watch('Gemfile')
  watch('spec/spec_helper.rb')  { :rspec }
  watch(%r{^features/support/}) { :cucumber }
end

guard 'rspec', :version => 2, :cli => "--color --drb --format Fuubar", :all_on_start => false, :all_after_pass => false, :notification => false do
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
end

guard 'cucumber', :cli => "--drb --format pretty --tags ~@wip", :all_on_start => false, :all_after_pass => false, :notification => false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
