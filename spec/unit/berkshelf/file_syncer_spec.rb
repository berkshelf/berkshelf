require 'spec_helper'

module Berkshelf
  describe FileSyncer do
    describe '#glob' do
      before do
        FileUtils.mkdir_p(File.join(tmp_path, 'folder'))
        FileUtils.mkdir_p(File.join(tmp_path, '.hidden_folder'))

        FileUtils.touch(File.join(tmp_path, 'folder', 'file'))
        FileUtils.touch(File.join(tmp_path, '.hidden_file'))
      end

      let(:list) do
        described_class
          .glob("#{tmp_path}/**/*")
          .map { |item| item.sub("#{tmp_path}/", '') }
      end

      it 'includes regular files' do
        expect(list).to include('folder')
        expect(list).to include('folder/file')
      end

      it 'ignores .' do
        expect(list).to_not include('.')
      end

      it 'ignores ..' do
        expect(list).to_not include('..')
      end

      it 'includes hidden files' do
        expect(list).to include('.hidden_file')
      end

      it 'includes hidden folders' do
        expect(list).to include('.hidden_folder')
      end
    end

    describe '#sync' do
      let(:source) do
        source = File.join(tmp_path, 'source')
        FileUtils.mkdir_p(source)

        FileUtils.touch(File.join(source, 'file_a'))
        FileUtils.touch(File.join(source, 'file_b'))
        FileUtils.touch(File.join(source, 'file_c'))

        FileUtils.mkdir_p(File.join(source, 'folder'))
        FileUtils.touch(File.join(source, 'folder', 'file_d'))
        FileUtils.touch(File.join(source, 'folder', 'file_e'))

        FileUtils.mkdir_p(File.join(source, '.dot_folder'))
        FileUtils.touch(File.join(source, '.dot_folder', 'file_f'))

        FileUtils.touch(File.join(source, '.file_g'))

        # VCS files: Arch
        FileUtils.mkdir_p(File.join(source, '.arch-ids'))
        FileUtils.mkdir_p(File.join(source, '{arch}'))

        # VCS files: Bazaar
        FileUtils.touch(File.join(source, '.bzr'))
        FileUtils.touch(File.join(source, '.bzrignore'))
        FileUtils.touch(File.join(source, '.bzrtags'))

        # VCS files: CVS
        FileUtils.mkdir_p(File.join(source, 'CVS'))
        FileUtils.touch(File.join(source, '.cvsignore'))

        # VCS files: Darcs
        FileUtils.touch(File.join(source, '_darcs'))

        # VCS files: git
        FileUtils.mkdir_p(File.join(source, '.git', 'objects', '08'))
        FileUtils.touch(File.join(source, '.git', 'HEAD'))
        git_readonly_file = File.join(source, '.git', 'objects', '08', '01ddba0b1237b2e0e602cf5fdb6544561950cb')
        FileUtils.touch(File.join(git_readonly_file))
        FileUtils.chmod("ugo=r", git_readonly_file)
        FileUtils.touch(File.join(source, '.gitignore'))

        # VCS files: Mercurial
        FileUtils.touch(File.join(source, '.hg'))
        FileUtils.touch(File.join(source, '.hgignore'))
        FileUtils.touch(File.join(source, '.hgrags'))

        # VCS files: RCS
        FileUtils.mkdir_p(File.join(source, 'RCS'))

        # VCS files: SCCS
        FileUtils.mkdir_p(File.join(source, 'SCCS'))

        # VCS files: Subversion
        FileUtils.mkdir_p(File.join(source, '.svn'))

        source
      end

      let(:destination) { File.join(tmp_path, 'destination') }

      context 'when the destination is empty' do
        it 'syncs the directories' do
          described_class.sync(source, destination)

          expect("#{destination}/file_a").to be_a_file
          expect("#{destination}/file_b").to be_a_file
          expect("#{destination}/file_c").to be_a_file
          expect("#{destination}/folder/file_d").to be_a_file
          expect("#{destination}/folder/file_e").to be_a_file
          expect("#{destination}/.dot_folder/file_f").to be_a_file
          expect("#{destination}/.file_g").to be_a_file
        end
      end

      context 'when the directory exists' do
        before { FileUtils.mkdir_p(destination) }

        it 'deletes existing files and folders' do
          FileUtils.mkdir_p("#{destination}/existing_folder")
          FileUtils.mkdir_p("#{destination}/.existing_folder")
          FileUtils.touch("#{destination}/existing_file")
          FileUtils.touch("#{destination}/.existing_file")

          described_class.sync(source, destination)

          expect("#{destination}/file_a").to be_a_file
          expect("#{destination}/file_b").to be_a_file
          expect("#{destination}/file_c").to be_a_file
          expect("#{destination}/folder/file_d").to be_a_file
          expect("#{destination}/folder/file_e").to be_a_file
          expect("#{destination}/.dot_folder/file_f").to be_a_file
          expect("#{destination}/.file_g").to be_a_file

          expect("#{destination}/existing_folder").to_not be_a_directory
          expect("#{destination}/.existing_folder").to_not be_a_directory
          expect("#{destination}/existing_file").to_not be_a_file
          expect("#{destination}/.existing_file").to_not be_a_file
        end

        it 'skips excluded VCS files' do
          described_class.sync(source, destination, exclude: Berksfile::EXCLUDED_VCS_FILES_WHEN_VENDORING)

          # VCS files: Arch
          expect("#{destination}/.arch-ids").to_not be_a_directory
          expect("#{destination}/{arch}").to_not be_a_directory

          # VCS files: Bazaar
          expect("#{destination}/.bzr").to_not be_a_file
          expect("#{destination}/.bzrignore").to_not be_a_file
          expect("#{destination}/.bzrtags").to_not be_a_file

          # VCS files: CVS
          expect("#{destination}/CVS").to_not be_a_directory
          expect("#{destination}/.cvsignore").to_not be_a_file

          # VCS files: Darcs
          expect("#{destination}/_darcs").to_not be_a_file

          # VCS files: git
          expect("#{destination}/.git/objects/08/01ddba0b1237b2e0e602cf5fdb6544561950cb").to_not be_a_file
          expect("#{destination}/.git/HEAD").to_not be_a_file
          expect("#{destination}/.git").to_not be_a_directory

          # VCS files: Mercurial
          expect("#{destination}/.hg").to_not be_a_file
          expect("#{destination}/.hgignore").to_not be_a_file
          expect("#{destination}/.hgrags").to_not be_a_file

          # VCS files: RCS
          expect("#{destination}/RCS").to_not be_a_directory

          # VCS files: SCCS
          expect("#{destination}/SCCS").to_not be_a_directory

          # VCS files: Subversion
          expect("#{destination}/.svn").to_not be_a_directory

        end
      end

      context 'with deeply nested paths and symlinks' do
        let(:source) do
          source = File.join(tmp_path, 'source')
          FileUtils.mkdir_p(source)

          FileUtils.mkdir_p(File.join(source, 'bin'))
               FileUtils.touch(File.join(source, 'bin', 'apt'))
               FileUtils.touch(File.join(source, 'bin', 'yum'))

          FileUtils.touch(File.join(source, 'LICENSE'))

          FileUtils.mkdir_p(File.join(source, 'include'))
          FileUtils.mkdir_p(File.join(source, 'include', 'linux'))
               FileUtils.touch(File.join(source, 'include', 'linux', 'init.ini'))

          FileUtils.mkdir_p(File.join(source, 'source'))
          FileUtils.mkdir_p(File.join(source, 'source', 'bin'))
               FileUtils.touch(File.join(source, 'source', 'bin', 'apt'))
               FileUtils.touch(File.join(source, 'source', 'bin', 'yum'))
               FileUtils.touch(File.join(source, 'source', 'LICENSE'))

          FileUtils.mkdir_p(File.join(source, 'empty_directory'))

          FileUtils.mkdir_p(File.join(source, 'links'))
                 FileUtils.touch(File.join(source, 'links', 'home.html'))
                 FileUtils.ln_s("./home.html", "#{source}/links/index.html")
                 FileUtils.ln_s("./home.html", "#{source}/links/default.html")
                 FileUtils.ln_s("../source/bin/apt", "#{source}/links/apt")

          FileUtils.ln_s('/foo/bar', "#{source}/root")

          source
        end

        it 'copies relative and absolute symlinks' do
          described_class.sync(source, destination)

          expect("#{destination}/bin").to be_a_directory
          expect("#{destination}/bin/apt").to be_a_file
          expect("#{destination}/bin/yum").to be_a_file

          expect("#{destination}/LICENSE").to be_a_file

          expect("#{destination}/include").to be_a_directory
          expect("#{destination}/include/linux").to be_a_directory
          expect("#{destination}/include/linux/init.ini").to be_a_file

          expect("#{destination}/source").to be_a_directory
          expect("#{destination}/source/bin").to be_a_directory
          expect("#{destination}/source/bin/apt").to be_a_file
          expect("#{destination}/source/bin/yum").to be_a_file
          expect("#{destination}/source/LICENSE").to be_a_file

          expect("#{destination}/empty_directory").to be_a_directory

          expect("#{destination}/links").to be_a_directory
          expect("#{destination}/links/home.html").to be_a_file
          expect("#{destination}/links/index.html").to be_a_symlink_to("./home.html")
          expect("#{destination}/links/default.html").to be_a_symlink_to("./home.html")
          expect("#{destination}/links/apt").to be_a_symlink_to("../source/bin/apt")

          expect("#{destination}/root").to be_a_symlink_to('/foo/bar')
        end

        it 'copies relative and absolute symlinks when destination is a relative path' do
          described_class.sync(source, "#{destination.gsub(Dir.pwd, '.')}")

          expect("#{destination}/links/index.html").to be_a_symlink_to("./home.html")
          expect("#{destination}/links/default.html").to be_a_symlink_to("./home.html")
          expect("#{destination}/links/apt").to be_a_symlink_to("../source/bin/apt")
          expect("#{destination}/root").to be_a_symlink_to('/foo/bar')
        end

      end

      context 'when :exclude is given' do
        it 'does not copy files and folders that match the pattern' do
          described_class.sync(source, destination, exclude: '.dot_folder')

          expect("#{destination}/file_a").to be_a_file
          expect("#{destination}/file_b").to be_a_file
          expect("#{destination}/file_c").to be_a_file
          expect("#{destination}/folder/file_d").to be_a_file
          expect("#{destination}/folder/file_e").to be_a_file
          expect("#{destination}/.dot_folder").to_not be_a_directory
          expect("#{destination}/.dot_folder/file_f").to_not be_a_file
          expect("#{destination}/.file_g").to be_a_file
        end

        it 'does not copy files and folder matching a pattern with a wildcard' do
          described_class.sync(source, destination, exclude: '**/file_e')

          expect("#{destination}/file_a").to be_a_file
          expect("#{destination}/file_b").to be_a_file
          expect("#{destination}/file_c").to be_a_file
          expect("#{destination}/folder/file_d").to be_a_file
          expect("#{destination}/folder/file_e").to_not be_a_file
          expect("#{destination}/.dot_folder").to be_a_directory
          expect("#{destination}/.dot_folder/file_f").to be_a_file
          expect("#{destination}/.file_g").to be_a_file
        end

        it 'removes existing files and folders in destination' do
          FileUtils.mkdir_p("#{destination}/existing_folder")
          FileUtils.touch("#{destination}/existing_file")
          FileUtils.mkdir_p("#{destination}/.dot_folder")
          FileUtils.touch("#{destination}/.dot_folder/file_f")

          described_class.sync(source, destination, exclude: '.dot_folder')

          expect("#{destination}/file_a").to be_a_file
          expect("#{destination}/file_b").to be_a_file
          expect("#{destination}/file_c").to be_a_file
          expect("#{destination}/folder/file_d").to be_a_file
          expect("#{destination}/folder/file_e").to be_a_file
          expect("#{destination}/.dot_folder").to_not be_a_directory
          expect("#{destination}/.dot_folder/file_f").to_not be_a_file
          expect("#{destination}/.file_g").to be_a_file

          expect("#{destination}/existing_folder").to_not be_a_directory
          expect("#{destination}/existing_file").to_not be_a_file
        end
      end
    end
  end
end
