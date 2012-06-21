require 'thor/group'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class InitGenerator < Thor::Group
    include Thor::Actions

    class_option :path,
      :type => :string,
      :required => true

    class_option :metadata_entry,
      :type => :boolean,
      :default => false

    class_option :chefignore,
      :type => :boolean,
      :default => false

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), "generator_files"))
    end

    def generate
      template "Berksfile.erb", File.join(target_path, "Berksfile")

      if options[:chefignore]
        copy_file "chefignore", File.join(target_path, ".chefignore")
      end
    end

    private

      def target_path
        @target_path ||= File.expand_path(options[:path])
      end
  end
end
