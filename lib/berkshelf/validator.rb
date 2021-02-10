module Berkshelf
  module Validator
    class << self
      # Perform a complete cookbook validation checking:
      #   * File names for inappropriate characters
      #   * Invalid Ruby syntax
      #   * Invalid ERB templates
      #
      # @param [Array<CachedCookbook>, CachedCookbook] cookbooks
      #   the Cookbook(s) to validate
      def validate(cookbooks)
        Array(cookbooks).each do |cookbook|
          validate_files(cookbook)
          cookbook.validate
        end
      end

      # Validate that the given cookbook does not have "bad" files. Currently
      # this means including spaces in filenames (such as recipes)
      #
      # @param [Array<CachedCookbook>, CachedCookbook] cookbooks
      #  the Cookbook(s) to validate
      def validate_files(cookbooks)
        Array(cookbooks).each do |cookbook|
          base, name = Pathname.new(cookbook.path.to_s).split

          files = Dir.glob("#{name}/**/*.rb", base: base.to_s).select { |f| f =~ /[[:space:]]/ }

          raise InvalidCookbookFiles.new(cookbook, files) unless files.empty?
        end
      end
    end
  end
end
