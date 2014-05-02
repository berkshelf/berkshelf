require 'spec_helper'

describe Berkshelf::Lockfile::Graph do
  let(:filepath) { fixtures_path.join('lockfiles/empty.lock').to_s }
  let(:lockfile) { Berkshelf::Lockfile.new(filepath: filepath) }
  subject { described_class.new(lockfile) }

  describe '#update' do
    it 'uses cookbook_name as GraphItem name' do
      cookbook = double('test',
        name: 'test-0.0.1',
        version: '0.0.1',
        cookbook_name: 'test',
        dependencies: {}
      )
      subject.update([cookbook])

      expect(subject.locks.keys).to include(cookbook.cookbook_name)
    end
  end
end
