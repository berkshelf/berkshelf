module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class TXResult < Struct.new(:status, :message, :source)
    def failed?
      status == :error
    end

    def success?
      status == :ok
    end
  end
end
