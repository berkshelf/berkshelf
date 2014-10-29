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
          path = cookbook.path.to_s

          files = Dir.glob(File.join(path, '**', '*.rb')).select do |f|
            parent = Pathname.new(path).dirname.to_s
            f.gsub(parent, '') =~ /[[:space:]]/
          end

          raise InvalidCookbookFiles.new(cookbook, files) unless files.empty?
        end
      end
    end
  end
end
