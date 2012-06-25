require 'thor/group'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class InitGenerator < Thor::Group
    class << self
      def source_root
        File.expand_path(File.join(File.dirname(__FILE__), "generator_files"))
      end
    end
    
    include Thor::Actions

    argument :path,
      :type => :string,
      :required => true

    class_option :metadata_entry,
      :type => :boolean,
      :default => false

    class_option :chefignore,
      :type => :boolean,
      :default => false

    def generate
      target_path = File.expand_path(path)

      template "Berksfile.erb", File.join(target_path, "Berksfile")

      if options[:chefignore]
        copy_file "chefignore", File.join(target_path, ".chefignore")
      end
    end
  end
end
