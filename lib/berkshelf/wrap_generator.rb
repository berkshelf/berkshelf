module Berkshelf
  class WrapGenerator < CookbookGenerator
    class_option :namespace,
      type: :string,
      default: Berkshelf::Config.instance.cookbook.namespace

    def generate
      empty_directory target.join('recipes')

      template 'default_recipe.erb', target.join('recipes/default.rb')
      template 'metadata_wrap.rb.erb', target.join('metadata.rb')
      template license_file, target.join('LICENSE')
      template 'README.md.erb', target.join('README.md')

      Berkshelf::InitGenerator.new([target], options.merge(default_options)).invoke_all
    end

    private

      def namespace
        options[:namespace] || 'chef-'
      end
  end
end
