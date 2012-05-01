require 'spec_helper'
require 'remy/dsl'

module Remy
  describe DSL do
    include DSL

    it 'should add the cookbooks to the shelf' do
      cookbook "ntp"
      cookbook "nginx"

      ['ntp', 'nginx'].each do |cookbook|
        Remy.shelf.cookbooks.should include cookbook
      end
    end
  end
end
