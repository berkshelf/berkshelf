module Berkshelf
  module Shelf
    class ListCommand < ShelfCommand
      def execute
        cookbooks = store.cookbooks.inject({}) do |hash, cookbook|
          (hash[cookbook.cookbook_name] ||= []).push(cookbook.version)
          hash
        end

        if cookbooks.empty?
          Berkshelf.formatter.msg 'There are no cookbooks in the Berkshelf shelf'
        else
          Berkshelf.formatter.msg 'Cookbooks in the Berkshelf shelf:'
          cookbooks.sort.each do |cookbook, versions|
            Berkshelf.formatter.msg("  * #{cookbook} (#{versions.sort.join(', ')})")
          end
        end
      end
    end
  end
end
