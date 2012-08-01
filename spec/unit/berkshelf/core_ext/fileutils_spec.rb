require 'spec_helper'

module Berkshelf
  describe FileUtils do
    describe '#ln_r' do
      it "should skip broken symlinks during traversal" do
        Dir.mktmpdir do |dir|
          path = Pathname.new(File.join(dir, 'ln_r_test'))
          Dir.mkdir(path)
          Dir.chdir(path) do
            File.open('original', 'w') {}
            File.symlink('original', 'link_to_original')
            FileUtils.rm('original')
          end
          -> { FileUtils.ln_r(path, File.join(dir, 'link_to_dir')) }.should_not raise_error
        end
      end
    end
  end
end
