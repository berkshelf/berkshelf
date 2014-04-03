guard 'spork' do
  watch('Gemfile')
  watch('spec/spec_helper.rb')  { :rspec }
  watch(%r{^features/support/}) { :cucumber }
end

rspec_cli = '--color --drb --format Fuubar'
rspec_cli += ' --tag ~@api_client --tag ~@not_supported_on_windows' if RUBY_PLATFORM =~ /mswin|mingw|windows/
guard 'rspec', cli: rspec_cli, all_on_start: false, all_after_pass: false do
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { 'spec' }
end

cucumber_cli = '--drb --format pretty --tags ~@no_run --tags ~@wip'
cucumber_cli += ' --tags ~@spawn --tags ~@api_server' if RUBY_PLATFORM =~ /mswin|mingw|windows/
guard 'cucumber', cli: cucumber_cli, all_on_start: false, all_after_pass: false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }

  watch(%r{^lib/berkshelf/cli.rb})                      { 'features' }
end
