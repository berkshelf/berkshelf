module Aruba
  # Force Aruba to behave like the SpawnProcess Aruba class.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class InProcess
    def stdin
      @stdin
    end

    def output
      stdout + stderr
    end
  end
end
