module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class InitGenerator < BaseGenerator
    argument :path,
      type: :string,
      required: true

    class_option :metadata_entry,
      type: :boolean,
      default: false

    class_option :chefignore,
      type: :boolean,
      default: false

    class_option :vagrant,
      type: :boolean,
      default: false

    class_option :git,
      type: :boolean,
      default: false

    class_option :foodcritic,
      type: :boolean,
      default: false

    class_option :no_bundler,
      type: :boolean,
      default: false

    def generate
      template "Berksfile.erb", target.join("Berksfile")

      if options[:chefignore]
        copy_file "chefignore", target.join("chefignore")
      end

      if options[:vagrant]
        template "Vagrantfile.erb", target.join("Vagrantfile")
      end

      if options[:git]
        copy_file "gitignore", target.join(".gitignore")
      end

      if options[:foodcritic]
        copy_file "Thorfile", target.join("Thorfile")
      end

      unless options[:no_bundler]
        template "Gemfile.erb", target.join("Gemfile")
      end
    end

    private

      def cookbook_name
        @cookbook_name ||= begin
          metadata = Chef::Cookbook::Metadata.new
          
          metadata.from_file(target.join("metadata.rb").to_s)
          metadata.name.empty? ? File.basename(target) : metadata.name
        rescue IOError
          File.basename(target)
        end
      end
  end
end
