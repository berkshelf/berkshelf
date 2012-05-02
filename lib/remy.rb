require 'dep_selector'
require 'zlib'
require 'archive/tar/minitar'
require 'chef/knife/cookbook_site_download'

require 'remy/shelf'
require 'remy/cookbook'
require 'remy/metacookbook'
require 'remy/dependency_reader'
require 'remy/dsl'
require 'remy/cheffile'


module Remy
  class << self
    def shelf
      @shelf ||= Remy::Shelf.new
    end

    def clear_shelf!
      @shelf = nil
    end

    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    end
  end
end
