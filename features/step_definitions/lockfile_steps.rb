Then(/^the output should warn about the old lockfile format$/) do
  message = Berkshelf::Lockfile.class_eval('LockfileLegacy.send(:warning_message)')
  expect(all_output).to include(message)
end

Given /^the Lockfile has:$/ do |table|
  result = { 'dependencies' => {} }

  table.raw.each do |name, locked_or_path, ref, rel|
    result['dependencies'][name] = {}

    if locked_or_path =~ /(\d+\.){2}\d/
      result['dependencies'][name]['locked_version'] = locked_or_path
    else
      result['dependencies'][name]['path'] = locked_or_path
    end

    unless ref.nil?
      result['dependencies'][name]['rel'] = ref
    end

    unless rel.nil?
      result['dependencies'][name]['rel'] = rel
    end
  end

  File.open(File.join(current_dir, 'Berksfile.lock'), 'w') do |file|
    file.write(JSON.pretty_generate(result) + "\n")
  end
end

Then /^the Lockfile should have:$/ do |table|
  hash = JSON.parse(File.read(File.join(current_dir, 'Berksfile.lock')))
  dependencies = hash['dependencies']

  table.raw.each do |name, locked_or_path, ref, rel|
    expect(dependencies).to have_key(name)

    if locked_or_path =~ /(\d+\.){2}\d/
      expect(dependencies[name]).to have_key('locked_version')
      expect(dependencies[name]['locked_version']).to eq(locked_or_path)
    else
      expect(dependencies[name]).to have_key('path')
      expect(dependencies[name]['path']).to eq(locked_or_path)
    end

    unless ref.nil?
      expect(dependencies[name]).to have_key('ref')
      expect(dependencies[name]['ref']).to eq(ref)
    end

    unless rel.nil?
      expect(dependencies[name]).to have_key('rel')
      expect(dependencies[name]['rel']).to eq(rel)
    end
  end
end
