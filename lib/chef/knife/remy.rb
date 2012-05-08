require 'chef/knife'
require 'remy'

module Remy
  module Knife
    class RemyInstall < Chef::Knife
      banner "knife remy install"

      def run
        ui.info 'Reading Cookbookfile'
        ::Remy.ui = ui
        ::Remy::Cookbookfile.process_install
      end
    end
  end
end
