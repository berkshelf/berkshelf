require_relative 'cli'

module Berkshelf
  class Main
    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      begin
        $stdin  = @stdin
        $stdout = @stdout
        $stderr = @stderr

        Berkshelf::Cli.start(@argv)
        @kernel.exit(0)
      rescue Berkshelf::BerkshelfError => e
        Berkshelf.ui.error e
        Berkshelf.ui.error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
        @kernel.exit(e.status_code)
      rescue Ridley::Errors::RidleyError => e
        Berkshelf.ui.error "#{e.class} #{e}"
        Berkshelf.ui.error "\t" + e.backtrace.join("\n\t") if ENV['BERKSHELF_DEBUG']
        @kernel.exit(47)
      end
    end
  end
end
