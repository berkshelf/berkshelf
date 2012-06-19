require 'pathname'

RSpec::Matchers.define :be_relative_path do
  match do |given|
    if given.nil?
      false
    else
      Pathname.new(given).relative?
    end
  end

  failure_message_for_should do |given|
    "Expected '#{given}' to be a relative path but got an absolute path."
  end

  failure_message_for_should_not do |given|
    "Expected '#{given}' to not be a relative path but got an absolute path."
  end
end
