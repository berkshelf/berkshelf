module KnifeCookbookDependencies
  class TXResult < Struct.new(:source, :status, :message)
    def failed?
      status == :error
    end

    def success?
      status == :ok
    end
  end
end
