require "spec_helper"

module Berkshelf
  describe Cli do
    let(:subject) { described_class.new }
    let(:berksfile) { double("Berksfile") }
    let(:cookbooks) { ["mysql"] }

    before do
      allow(Berksfile).to receive(:from_options).and_return(berksfile)
    end

    describe "#upload" do
      it "calls to upload with params if passed in cli" do
        expect(berksfile).to receive(:upload).with(cookbooks,
          include(skip_syntax_check: true, freeze: false)
        )

        subject.options[:skip_syntax_check] = true
        subject.options[:no_freeze]         = true
        subject.upload("mysql")
      end
    end

    describe 'command plugins' do
      it 'runs berks-foo when called as berks foo' do
        File.open(tmp_path.join("berks-foo"), 'w', 0755) do |file|
          file.write("#!/bin/sh\necho 'it works'\n")
        end

        # We need to set the path to include our new plugin command
        old_path = ENV['PATH']
        ENV['PATH'] = "#{tmp_path}:#{ENV['PATH']}"

        # fork because the command is expected to exit the process completely
        pipe_me, pipe_peer = IO.pipe
        pid = fork do
          $stdout.reopen(pipe_peer)
          # Run 'berks foo'
          Berkshelf::Cli::Runner.new(['foo']).execute!
        end
        Process.waitpid(pid)
        pipe_peer.close
        output = pipe_me.read

        # Restore the old path
        ENV['PATH'] = old_path

        expect(output).to eq "it works\n"
      end
    end
  end
end
