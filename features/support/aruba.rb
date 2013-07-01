module Aruba
  # Force Aruba to behave like the SpawnProcess Aruba class.
  class InProcess
    def stdin
      @stdin
    end

    def output
      stdout + stderr
    end
  end
end
