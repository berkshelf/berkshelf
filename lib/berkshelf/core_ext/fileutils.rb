module FileUtils
  # @note taken from proposed FileUtils feature:
  # @note {http://redmine.ruby-lang.org/issues/show/4189}
  # @note {https://github.com/ruby/ruby/pull/4}
  #
  # Options: noop verbose dereference_root force
  #
  # Hard link +src+ to +dest+. If +src+ is a directory, this method links
  # all its contents recursively. If +dest+ is a directory, links
  # +src+ to +dest/src+.
  #
  # +src+ can be a list of files.
  #
  #   # Installing ruby library "mylib" under the site_ruby
  #   FileUtils.rm_r site_ruby + '/mylib', :force
  #   FileUtils.ln_r 'lib/', site_ruby + '/mylib'
  #
  #   # Examples of copying several files to target directory.
  #   FileUtils.ln_r %w(mail.rb field.rb debug/), site_ruby + '/tmail'
  #   FileUtils.ln_r Dir.glob('*.rb'), '/home/aamine/lib/ruby', :noop => true, :verbose => true
  #
  #   # If you want to copy all contents of a directory instead of the
  #   # directory itself, c.f. src/x -> dest/x, src/y -> dest/y,
  #   # use following code.
  #   FileUtils.ln_r 'src/.', 'dest'     # cp_r('src', 'dest') makes src/dest,
  #                                      # but this doesn't.
  def ln_r(src, dest, options = {})
    fu_check_options options, OPT_TABLE['ln_r']
    fu_output_message "ln -r#{options[:force] ? ' --remove-destination' : ''} #{[src,dest].flatten.join ' '}" if options[:verbose]
    return if options[:noop]
    options = options.dup
    options[:dereference_root] = true unless options.key?(:dereference_root)
    fu_each_src_dest(src, dest) do |s, d|
      link_entry s, d, options[:dereference_root], options[:force]
    end
  end
  module_function :ln_r

  OPT_TABLE['ln_r'] = [:noop, :verbose, :dereference_root, :force]

  #
  # Hard links a file system entry +src+ to +dest+.
  # If +src+ is a directory, this method links its contents recursively.
  #
  # Both of +src+ and +dest+ must be a path name.
  # +src+ must exist, +dest+ must not exist.
  #
  # If +dereference_root+ is true, this method dereference tree root.
  #
  # If +force+ is true, this method removes each destination file before copy.
  #
  def link_entry(src, dest, dereference_root = false, force = false)
    Entry_.new(src, nil, dereference_root).traverse do |ent|
      destent = Entry_.new(dest, ent.rel, false)
      File.unlink destent.path if force && File.file?(destent.path)
      ent.link destent.path
    end
  end
  module_function :link_entry

  private

    class Entry_ #:nodoc:
      def link(dest)
        case
        when broken_symlink?
          warn "#{path} is a broken symlink. No link created."
        when directory?
          if !File.exist?(dest) and descendant_diretory?(dest, path)
            raise ArgumentError, "cannot link directory %s to itself %s" % [path, dest]
          end
          begin
            Dir.mkdir dest
          rescue
            raise unless File.directory?(dest)
          end
        else
          File.link path(), dest
        end
      end

      # Check if the file at path is a broken symlink
      #
      # @return [Boolean]
      def broken_symlink?
        File.symlink?(path) && !File.exists?(File.readlink(path))
      end

    end
end
