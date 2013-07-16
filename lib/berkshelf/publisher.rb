module Berkshelf
  class Publisher
    include Mixin::Tar

    def publish(path, options = {})
      begin
        cookbook = CachedCookbook.from_path(path)
        cookbook.validate
      rescue => ex
        raise PublishError, ex
      end

      upload archive(cookbook), options
    end

    private

      # @param [CachedCookbook] cookbook
      #
      # @return [StringIO]
      def archive(cookbook)
        tar(cookbook.path, gzip: true)
      end

      # @param [StringIO] stream
      def upload(stream, options = {})
        puts "uploading #{archive}"
      end
  end
end
