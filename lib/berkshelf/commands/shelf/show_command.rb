module Berkshelf
  module Shelf
    class ShowCommand < ShelfCommand
      parameter 'NAME', 'cookbook to show'
      parameter '[VERSION]', 'version to display (default: all versions)'

      def execute
        cookbooks = find(name, version)

        if version
          Berkshelf.formatter.msg "Displaying '#{name}' (#{version}) in the Berkshelf shelf:"
        else
          Berkshelf.formatter.msg "Displaying all versions of '#{name}' in the Berkshelf shelf:"
        end

        cookbooks.each do |cookbook|
          Berkshelf.formatter.show(cookbook)
          Berkshelf.formatter.msg("\n")
        end
      end
    end
  end
end
