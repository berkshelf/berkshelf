class RBzip2::Decompressor
  def pos ; end
  def pos=(*args) ; end
  
  def eof?
    @io.eof?
  end
end
