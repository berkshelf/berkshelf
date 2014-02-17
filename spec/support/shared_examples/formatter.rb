module Berkshelf
  shared_examples 'a formatter object' do
    BaseFormatter.instance_methods(false).each do |name|
      next if name == :cleanup_hook

      it "implements ##{name}" do
        expect(subject.method(name).owner).to eq(described_class)
      end
    end
  end
end
