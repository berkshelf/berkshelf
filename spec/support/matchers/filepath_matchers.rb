require 'rspec/expectations'
require 'pathname'

RSpec::Matchers.define :be_relative_path do
  match do |given|
    if given.nil?
      false
    else
      Pathname.new(given).relative?
    end
  end

  failure_message do |given|
    "Expected '#{given}' to be a relative path but got an absolute path."
  end

  failure_message_when_negated do |given|
    "Expected '#{given}' to not be a relative path but got an absolute path."
  end
end

# expect('/path/to/directory').to be_a_directory
RSpec::Matchers.define :be_a_directory do
  match do |actual|
    File.directory?(actual)
  end
end

# expect('/path/to/directory').to be_a_file
RSpec::Matchers.define :be_a_file do
  match do |actual|
    File.file?(actual)
  end
end

# expect('/path/to/directory').to be_a_symlink
RSpec::Matchers.define :be_a_symlink do
  match do |actual|
    File.symlink?(actual)
  end
end

# expect('/path/to/directory').to be_a_symlink_to
RSpec::Matchers.define :be_a_symlink_to do |path|
  match do |actual|
    File.symlink?(actual) && File.readlink(actual) == path
  end
end

# expect('/path/to/file').to be_an_executable
RSpec::Matchers.define :be_an_executable do
  match do |actual|
    File.executable?(actual)
  end
end
