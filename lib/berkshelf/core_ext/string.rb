class String
  # Separates the string on the given separator and prepends the given
  # value to each and returns a new string from the result.
  #
  # @param [String] separator
  # @param [String] value
  #
  # @return [String]
  def prepend_each(separator, value)
    lines(separator).collect { |x| value + x }.join
  end
end
