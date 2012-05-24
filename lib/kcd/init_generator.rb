require 'thor/group'

module KnifeCookbookDependencies
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
      validate_path!

      # Temporarily always create the Cookbookfile without the 'metadata'
      # entry. This cannot happen until we actually have support for the
      # metadata keyword in the Cookbookfile.
      create_cookbookfile(false)
      # create_cookbookfile(options[:metadata_entry])

      if options[:chefignore]
        create_chefignore
      end
    end

    private

      def target_path
        @target_path ||= File.expand_path(options[:path])
      end

      def create_cookbookfile(include_metadata)
        template "Cookbookfile.erb", File.join(target_path, "Cookbookfile")
      end

      def create_chefignore
        copy_file "chefignore", File.join(target_path, ".chefignore")
      end

      def validate_path!
        # validate this shit
        true
      end
  end
end
