module Berkshelf
  class Publisher
    require_relative 'publisher/packager'

    def initialize
      @conn = CommunityREST.new
    end

    def publish(path, options = {})
      begin
        cookbook = CachedCookbook.from_path(path)
        cookbook.validate
      rescue => ex
        raise PublishError, ex
      end

      upload Packager.package(cookbook), options
    end

    private

      # @return [Berkshelf::CommunityREST]
      attr_reader :conn

      # @param [StringIO] stream
      def upload(stream, options = {})
        puts "uploading #{archive}"
        conn.upload(cookbook)
      end
  end
end
