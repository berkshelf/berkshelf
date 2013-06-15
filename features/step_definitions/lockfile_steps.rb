Then(/^the output should warn about the old lockfile format$/) do
  message = Berkshelf::Lockfile.class_eval('LockfileLegacy.send(:warning_message)')
  expect(all_output).to include(message)
end
